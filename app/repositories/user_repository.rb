class UserRepository
  def initialize
  end

  def get_user(userId)
    return User.find(userId)
  end

  def get_user_org(userId)
    # TODO Not sure if this works in a single call, may need to adjust associations
    return User.includes(:organization).find(userId).organization
  end

  def update_user_info(userObj)
    id = userObj[:id]
    email = userObj[:email]
    first_name = userObj[:first_name]
    last_name = userObj[:last_name]
    title = userObj[:title]
    phone = userObj[:phone]
    avatar = userObj[:avatar]
    class_of = userObj[:class_of]
    time_unit_id = userObj[:time_unit_id]

    user = User.find(id)
    user.email = email
    user.first_name = first_name
    user.last_name = last_name
    user.title = title
    user.phone = phone
    user.class_of = class_of
    user.time_unit_id = time_unit_id

    if avatar != nil
      user.avatar = avatar
    end

    if user.save
      return { :status => :ok, :info => "User info updated successfully!", :user => user }
    else
      return { :status => :bad_request, :info => user.errors.full_messages, :user => user}
    end
  end

  def update_password(user_obj)
    id = user_obj[:id]
    current_password = user_obj[:current_password]
    password = user_obj[:password]
    password_confirmation = user_obj[:password_confirmation]

    user = User.find(id)

    if (user.update_with_password(user_obj))
      new_user = get_user(id)

      return { :status => :ok, :info => "Password updated successfully!", :user=>new_user }
    else
      old_user = get_user(id)

      return { :status => :bad_request, :info => user.errors.full_messages, :user=>old_user }
    end
  end

  def create_user(user_obj, current_user)
    if user_obj[:organization_id].nil? && user_obj[:role] != Constants.UserRole[:SUPER_ADMIN]
      return { :status => :bad_request, :info => "You must assign this user to an organization", :user => nil }
    elsif User.where(:email=> user_obj[:email]).length != 0
      return { :status => :conflict, :info => "A user with the email #{user_obj[:email]} already exists.", :user => nil }
    end

    password = generate_password()
    user = User.new do |u|
      u.email = user_obj[:email]
      u.first_name = user_obj[:first_name]
      u.last_name = user_obj[:last_name]
      u.title = user_obj[:title]
      u.phone = user_obj[:phone]
      u.role = user_obj[:role]
      u.organization_id = user_obj[:organization_id]
      u.time_unit_id = user_obj[:time_unit_id]
      u.password = password
      u.status = user_obj[:status]
    end

    if user.role == Constants.UserRole[:STUDENT]
      user.class_of = user_obj[:class_of]
    end

    if user.save
      # Send emails out of process
      # https://www.agileplannerapp.com/blog/building-agile-planner/rails-background-jobs-in-threads
      Background.process do
        UserMailer.welcome(user, password).deliver
        UserMailer.new_user(user, current_user).deliver
      end

      # Considered making this a background process, but what if background processing
      # was behind like 5min for whatever reason?
      if user.role == Constants.UserRole[:STUDENT]
        # Change this to passing in @current_user when user_repository is updated to
        # be initialized with current_user
        UserExpectationService.new(User.SystemUser).create_user_expectations(user.id)
      end

      return { :status => :ok, :info => "User created successfully. Email has been sent.", :user => user }
    end

    return { :status => :internal_server_error, :info => "Failed to create user.", :user => nil }
  end

  def generate_password
    return Devise.friendly_token.first(8)
  end

  def reset_password(user)
    new_password = generate_password()

    user.update_attributes(:password => new_password)

    Background.process do
      UserMailer.reset_password(user, new_password).deliver
    end
  end

  # will require authentication when put into UI
  def reset_all_students_password(organization_id)
    Background.process do
      users = User.where(:role => 50, :organization_id => organization_id)
      users.each do |u|
        new_password = generate_password()
        u.update_attributes(:password => new_password)
        UserMailer.reset_password(u, new_password).deliver
      end
    end

    return { :status => :ok,
             :info => "Successfully reset all students' passwords"
           }
  end

  # will require authentication when put into UI
  def reset_users_password(user_ids, organization_id)
    Background.process do
      user_ids.each do |id|
        user = User.find(id)
        if organization_id == user.organization_id
          new_password = generate_password()
          user.update_attributes(:password => new_password)
          UserMailer.reset_password(user, new_password).deliver
        end
      end
    end

    return { :status => :ok,
             :info => "Successfully reset passwords"
           }
  end

  def delete_user(userId)
    if User.find(userId).destroy
      return { :status => :ok, :info => "User deleted successfully" }
    else
      return { :status => :internal_server_error, :info => "Failed to delete user." }
    end
  end

  def move_to_next_semester(userId)
    user = get_user(userId)
    time_units = RoadmapRepository.new.get_time_units(user.organization_id)

    next_time_unit = time_units.select{|tu| tu.id == (user.time_unit_id + 1)}.first

    if next_time_unit.nil?
      return ReturnObject.new(:bad_request, "Next semester does not exist. Current sem id: #{user.time_unit_id}", nil)
    end

    user.time_unit_id = next_time_unit.id

    if user.save
      return ReturnObject.new(:ok, "User moved to next semester successfully", user)
    else
      return ReturnObject.new(:internal_server_error, "Failed to move User to next semester", nil)
    end
  end

  def move_to_prev_semester(userId)
    user = get_user(userId)
    time_units = RoadmapRepository.new.get_time_units(user.organization_id)

    prev_time_unit = time_units.select{|tu| tu.id == (user.time_unit_id - 1)}.first

    if prev_time_unit.nil?
      return ReturnObject.new(:bad_request, "Previous semester does not exist. Current sem id: #{user.time_unit_id}", nil)
    end

    user.time_unit_id = prev_time_unit.id

    if user.save
      return ReturnObject.new(:ok, "User moved to previous semester successfully", user)
    else
      return ReturnObject.new(:internal_server_error, "Failed to move User to previous semester", nil)
    end
  end

  def assign(mentor_id, student_id)
    student = get_user(student_id)
    if get_user(mentor_id).nil? || student.nil?
      return ReturnObject.new(:bad_request, "One of your user's in the relationship does not exist", nil)
    end

    if Relationship.where(:user_id => student_id, :assigned_to_id => mentor_id).length > 0
      return ReturnObject.new(:conflict, "This relationship already exists", nil)
    end

    relationship = Relationship.new do | r |
      r.user_id = student_id
      r.assigned_to_id = mentor_id
    end

    if relationship.save
      send_assigned_notification(mentor_id, student_id)
      return ReturnObject.new(:ok, "User #{student_id} successfully assigned to #{mentor_id}", student)
    else
      return ReturnObject.new(:internal_server_error, relationship.errors, nil)
    end
  end

  def unassign(mentor_id, student_id)
    if Relationship.where(:user_id => student_id, :assigned_to_id => mentor_id).destroy_all()
      send_unassigned_notification(mentor_id, student_id)
      return ReturnObject.new(:ok, "User #{student_id} successfully unassigned from #{mentor_id}", nil)
    else
      return ReturnObject.new(:internal_server_error, "User #{student_id} could not be unassigned from #{mentor_id}", nil)
    end
  end

  def get_assigned_students(userId)
    studentIds = get_assigned_student_ids(userId)

    students = User.includes([:user_milestones, :relationships, :user_expectations,
                   :user_classes, :user_extracurricular_activity_details,
                   :user_service_hours, :user_tests]).where(:id => studentIds)

    return students
  end

  def get_assigned_student_ids(userId)
    return Relationship.where(:assigned_to_id => userId).map(&:user_id)
  end

  def get_assigned_students_for_group(userIds)
    assigned_students_for_group = []

    userIds.each do | userId |
      studentIds = []

      students = get_assigned_students(userId)
      students.each do | student |
        studentIds << student.id
      end

      assigned_students_for_group << { :user_id => userId, :student_ids => studentIds}
    end

    return ReturnObject.new(:ok, "Assigned students for users: #{userIds}.", assigned_students_for_group)
  end

  def get_assigned_mentors(userId)
    relations = Relationship.where(:user_id => userId)

    mentors = []
    relations.each do | r |
      mentors << get_user(r.assigned_to_id)
    end

    return mentors
  end

  def are_related?(studentId, mentorId)
    return Relationship.where(:user_id => studentId, :assigned_to_id => mentorId).length > 0
  end

  def send_assigned_notification(mentorId, studentId)
    Background.process do
      mentor = get_user(mentorId)
      student = get_user(studentId)

      RelationshipMailer.assigned_student_to_mentor(mentor, student).deliver
    end
  end

  def send_unassigned_notification(mentorId, studentId)
    Background.process do
      mentor = get_user(mentorId)
      student = get_user(studentId)

      RelationshipMailer.unassigned_student_from_mentor(mentor, student).deliver
    end
  end
end
