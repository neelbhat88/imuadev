class Api::V1::UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

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
    # Temporary security check
    if !current_user.super_admin?
      render status: 401,
        json: {
          success: false
        }
    end

    email = params[:email]
    first_name = params[:first_name]
    last_name = params[:last_name]
    role = params[:role].to_i

    user = { :first_name => first_name,
             :last_name => last_name,
             :email => email,
             :role => role  }

    result = UserRepository.new.create_user(user, current_user)

    render status: 200,
    json: {
      success: result[:success],
      info: result[:info]
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

    render status: 200,
    json: {
      success: result[:success],
      info: result[:info],
      user: result[:user]
    }
  end

  # DELETE /users/:id
  def delete
    # Temporary security check
    if !current_user.super_admin?
      render status: 401,
        json: {
          success: false
        }
    end

    result = UserRepository.new.delete_user(params[:id])

    render status: 200,
    json: {
      success: result[:success],
      info: result[:info]
    }
  end

  # PUT /users/:id/update_password
  def update_password
    userObj = params[:user]

    result = UserRepository.new.update_password(userObj)

    if (result[:success])
      sign_in result[:user], :bypass => true
    end

    render status: 200,
    json: {
      success: result[:success],
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