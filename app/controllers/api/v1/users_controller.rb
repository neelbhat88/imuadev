class Api::V1::UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # GET /users
  def index
    render status: 200,
      json: {
        success: true,
        info: "User",
        user: "Index on User"
      }
  end

  # POST /users
  def create
    email = params[:user][:email]
    first_name = params[:user][:first_name]
    last_name = params[:user][:last_name]
    phone = params[:user][:phone]
    role = params[:user][:role].to_i
    orgId = params[:user][:organization_id].to_i
    class_of = params[:user][:class_of].to_i

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
             :phone => phone,
             :role => role,
             :organization_id => orgId,
             :class_of => class_of}

    result = UserRepository.new.create_user(user, current_user)

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
    # Temporary security check
    if !current_user.super_admin?
      render status: :unauthorized,
        json: {
          into: "This user is not allowed to perform this action."
        }

      return
    end

    result = UserRepository.new.delete_user(params[:id])

    render status: result[:status],
    json: {
      info: result[:info]
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

    students = UserRepository.new.get_assigned_students(userId)

    viewStudents = students.map {|s| ViewUser.new(s)}
    render status: :ok,
      json: {
        info: "Assigned students",
        students: viewStudents
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
