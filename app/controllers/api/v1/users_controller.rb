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
		render status: 200,
			json: {
				success: true,
				info: "User",
				user: "Create on User"
			}
	end

	# GET /users/:id
	def show
	end

	# PUT /users/:id
	def update
		user = params[:user]

		result = UserRepository.new.update_user_info(user)

		UserMailer.welcome(current_user, 'password').deliver

		render status: 200,
		json: {
			success: result[:success],
			info: result[:info],
			user: result[:user]
		}		
	end

	# DELETE /users/:id
	def delete
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

class UserRepository
	def initialize
	end

	def get_user(userId)
		return User.find(userId)
	end

	def update_user_info(user)
		result = User.find(user[:id])
									.update_attributes( :first_name => user[:first_name], 
																			:last_name => user[:last_name],
																			:phone => user[:phone] )

		if (result)			
			return { :success => true, :info => "User info updated successfully!", :user => user }
		
		else
			old_user = get_user(user[:id])

			return { :success => false, :info => "Failed to update user info.", :user => old_user}
		end
	end

	def update_password(user_obj)
		id = user_obj[:id]
		current_password = user_obj[:current_password]
		password = user_obj[:password]
		password_confirmation = user_obj[:password_confirmation]

		user = get_user(id)

		if (user.update_with_password(user_obj))
			return { :success => true, :info => "Password updated successfully!", :user=>user }
		else
			return { :success => false, :info => user.errors.full_messages, :user=>user }
		end
	end
end


# ToDo, this can be used for Global Exception handling
		# begin
		# rescue => e
		# 	user = UserRepository.new.get_user(user[:id])

		# 	refId = SecureRandom.uuid
		# 	logger.error("Error: RefId: #{refId}. Exception: #{e.message}. Backtrace: #{e.backtrace}")

		# 	render status: 200,
		# 	json: {
		# 		success: false,
		# 		info: "Failed to save user info. Reference Id: #{refId}",
		# 		user: user
		# 	}

		# end