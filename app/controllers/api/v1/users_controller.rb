class Api::V1::UsersController < ApplicationController
  respond_to :json

  skip_before_filter :authenticate_token
  #skip_before_filter :authenticate_token, only: [:reset_password]
  before_filter :load_services

  def load_services( assignmentService = nil, userService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new(current_user)
    @userService = userService ? userService : UserService.new(current_user)
  end

  # GET /users
  def index
    render status: 200,
      json: {
        answers: Question.order(:qnumber).all
      }
  end

  # POST /users
  def create
    email = params[:user][:email]
    title = params[:user][:title]
    first_name = params[:user][:first_name]
    last_name = params[:user][:last_name]
    phone = params[:user][:phone]
    role = params[:user][:role].to_i
    orgId = params[:user][:organization_id].to_i
    class_of = params[:user][:class_of].to_i
    time_unit_id = params[:user][:time_unit_id]
    status = params[:user][:status]

    # Temporary security check - need to find a better way to do this
    if !current_user.super_admin? && role == Constants.UserRole[:SUPER_ADMIN]
      render status: :unauthorized,
        json: {
          info: "You do not have sufficient permissions to create the user."
        }

      return
    end

    organization = OrganizationRepository.new.get_organization(orgId)
    if organization.nil? || !can?(current_user, :create_user, organization)
      render status: :forbidden, json: {}
      return
    end

    user = { :first_name => first_name,
             :last_name => last_name,
             :email => email,
             :title => title,
             :phone => phone,
             :role => role,
             :organization_id => orgId,
             :class_of => class_of,
             :time_unit_id => time_unit_id,
             :status => status}

    result = UserRepository.new.create_user(user, current_user)

    Background.process do
      SlackNotifier.new.user_created(current_user, result[:user])
    end

    viewUser = ViewUser.new(result[:user]) unless result[:user].nil?
    render status: result[:status],
    json: {
      info: result[:info],
      user: viewUser
    }
  end

  # GET /users/:id
  def show
    userId = params[:id].to_i
    user = UserRepository.new.get_user(userId)

    if !can?(current_user, :view_profile, user)
      render status: :forbidden,
        json: {}
      return
    end

    viewUser = ViewUser.new(user) unless user.nil?
    render status: :ok,
      json: {
        info: "User",
        user: viewUser
      }
  end

  # PUT /users/:id
  def update
    user = params[:user]
    user[:id] = params[:id]

    # ToDo: Add authorization check here
    result = UserRepository.new.update_user_info(user)

    viewUser = ViewUser.new(result[:user]) unless result[:user].nil?
    render status: result[:status],
    json: {
      info: result[:info],
      user: viewUser
    }
  end

  # DELETE /users/:id
  def destroy
    user_id = params[:id]

    user = User.find(user_id)

    if !can?(current_user, :delete_user, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = UserRepository.new.delete_user(user)

    Background.process do
      SlackNotifier.new.user_deleted(current_user, user)
    end

    render status: result[:status],
    json: {
      info: result[:info]
    }
  end

  # GET /users/:id/user_with_contacts
  def get_user_with_contacts
    userId = params[:id]

    viewUser = nil
    user = UserRepository.new.get_user(userId)
    if can?(current_user, :view_profile, user)
      viewUser = ViewUser.new(user)
    end

    viewContacts = nil
    if can?(current_user, :read_parent_guardian_contacts, user)
      contacts = ParentGuardianContactService.new.get_parent_guardian_contacts(userId)
      viewContacts = contacts.map{|c| ViewParentGuardianContact.new(c)}
    end

    # TODO Make this fit in better
    timeUnits = RoadmapRepository.new.get_time_units(user.organization_id) unless user.nil?

    render status: :ok,
    json: {
      info: "User info with contacts for userId: #{userId}.",
      # TODO Replace with ViewUser
      user_with_contacts: { :user => viewUser, :contacts => viewContacts, :time_units => timeUnits }
    }
  end

  # PUT /users/:id/update_password
  def update_password
    userObj = params[:user]

    result = UserRepository.new.update_password(userObj)

    if (result[:status] == :ok)
      sign_in result[:user], :bypass => true
    end

    render status: result[:status],
    json: {
      info: result[:info]
    }
  end

  # PUT /users/:id/time_unit/next
  def move_to_next_semester
    userId = params[:id]

    result = UserRepository.new.move_to_next_semester(userId)

    render status: result.status,
      json: {
        info: result.info,
        user: result.object
      }
  end

  # PUT /users/:id/time_unit/previous
  def move_to_prev_semester
    userId = params[:id]

    result = UserRepository.new.move_to_prev_semester(userId)

    render status: result.status,
      json: {
        info: result.info,
        user: result.object
      }
  end

  # POST /users/:id/relationship/:assignee_id
  def assign
    userId = params[:id].to_i
    assignee_id = params[:assignee_id].to_i

    result = UserRepository.new.assign(userId, assignee_id)

    viewUser = ViewUser.new(result.object) unless result.object.nil?
    render status: result.status,
        json: {
          info: result.info,
          student: viewUser
        }
  end

  # DELETE /users/:id/relationship/:assignee_id
  def unassign
    userId = params[:id].to_i
    assignee_id = params[:assignee_id].to_i

    result = UserRepository.new.unassign(userId, assignee_id)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # GET /users/:id/relationship/students
  def get_assigned_students
    userId = params[:id].to_i
    userRepo = UserRepository.new

    org = userRepo.get_user_org(userId)

    options = {}
    options[:user_ids] = userRepo.get_assigned_student_ids(userId)
    viewOrg = ViewOrganizationWithUsers.new(org, options) unless org.nil?

    render status: :ok,
      json: {
        info: "Organization with assigned students",
        organization: viewOrg
      }
  end

  # GET /relationship/assigned_students_for_group?user_ids[]=#
  def get_assigned_students_for_group
    userIds = params[:user_ids]

    userIds.each do | userId |
      # TODO
      # user = UserRepository.new.get_user(userId)
      # if !can?(current_user, :read_assigned_students, user)
      #   render status: :forbidden,
      #     json: {}
      #   return
    end

    result = UserRepository.new.get_assigned_students_for_group(userIds)

    render status: result.status,
      json: {
        info: result.info,
        assigned_students_for_group: result.object
      }
  end

  # GET /users/:id/relationship/mentors
  def get_assigned_mentors
    userId = params[:id].to_i

    mentors = UserRepository.new.get_assigned_mentors(userId)

    viewMentors = mentors.map {|s| ViewUser.new(s)}
    render status: :ok,
      json: {
        info: "Assigned mentors",
        mentors: viewMentors
      }
  end

  # PUT organization/:id/users/reset_all_students_password
  def reset_all_students_password
    organization_id = params[:id].to_i
    organization = OrganizationRepository.new.get_organization(organization_id)

    if can?(current_user, :reset_passwords, organization)
      result = UserRepository.new.reset_all_students_password(organization_id)
    else
      result = { :status => :forbidden,
                 :info => "You are not permitted to reset students' passwords"
               }
    end

    render status: result[:status],
    json: {
      info: result[:info]
    }
  end

  # PUT organization/:id/users/reset_users_password
  def reset_users_password
    organization_id = params[:id].to_i
    organization = OrganizationRepository.new.get_organization(organization_id)
    user_ids = params[:user_ids]

    if can?(current_user, :reset_passwords, organization)
      result = UserRepository.new.reset_users_password(user_ids, organization_id)
    else
      result = { :status => :forbidden,
                 :info => "You are not permitted to reset students' passwords"
               }
    end

    render status: result[:status],
    json: {
      info: result[:info]
    }
  end

##############
# Assignment #
##############

  # POST /users/:id/assignment
  def assignment
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "User"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(@current_user, :create_assignment, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.create(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # POST /users/:id/create_assignment_broadcast
  def create_assignment_broadcast
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "User"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(@current_user, :create_assignment_broadcast, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.create_broadcast(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /users/:id/assignments
  def assignments
    service_params = params.except(*[:id, :controller, :action]).symbolize_keys
    service_params[:assignment_owner_id] = params[:id].to_i
    service_params[:assignment_owner_type] = "User"

    owner_object = service_params[:assignment_owner_type].classify.constantize.where(id: service_params[:assignment_owner_id]).first
    if !can?(@current_user, :index_assignments, owner_object)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.index(service_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /users/:id/get_task_assignable_users
  def get_task_assignable_users
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    if !can?(current_user, :get_task_assignable_users, User.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @userService.get_task_assignable_users(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # GET /users/:id/get_task_assignable_users_tasks
  def get_task_assignable_users_tasks
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:user_id] = params[:id]

    if !can?(current_user, :get_task_assignable_users_tasks, User.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @userService.get_task_assignable_users_tasks(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

########################
# Unaunthenticated calls
########################

  # POST /users/password
  def reset_password
    email = params[:user][:email]

    if email.blank?
      render status: :bad_request,
      json: {
        message: "You must enter an email"
      }
      return false
    end

    user = User.find_by_email(email)
    if user.nil?
      render status: :bad_request,
      json: {
        message: "User does not exist"
      }
      return false
    end

    UserRepository.new.reset_password(user)

    render status: :ok,
      json: {
        message: "Password reset successfully! Check your email for your password reset instructions"
      }
  end

end


# ToDo, this can be used for Global Exception handling
    # begin
    # rescue => e
    #   user = UserRepository.new.get_user(user[:id])

    #   refId = SecureRandom.uuid
    #   logger.error("Error: RefId: #{refId}. Exception: #{e.message}. Backtrace: #{e.backtrace}")

    #   render status: 200,
    #   json: {
    #     success: false,
    #     info: "Failed to save user info. Reference Id: #{refId}",
    #     user: user
    #   }

    # end
