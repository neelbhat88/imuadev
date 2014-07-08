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

    # Temporary security check - need to find a better way to do this
    if !current_user.super_admin? && role == Constants.UserRole[:SUPER_ADMIN]
      render status: :unauthorized,
        json: {
          info: "You do not have sufficient permissions to create the user."
        }

      return
    end

    user = { :first_name => first_name,
             :last_name => last_name,
             :email => email,
             :phone => phone,
             :role => role,
             :organization_id => orgId }

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
  end

  # PUT /users/:id
  def update
    user = params[:user]
    user[:id] = params[:id]

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
