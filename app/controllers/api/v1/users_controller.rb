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
						 :role => role	}

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

	def create_user(user_obj, current_user)
		password = Devise.friendly_token.first(8)

		success = User.create(:email => user_obj[:email], 
								:first_name => user_obj[:first_name], 
								:last_name => user_obj[:last_name], 								
								:role => user_obj[:role],
								:password => password)

		if success
			user = User.find_by_email(user_obj[:email])
			UserMailer.welcome(user, password).deliver
			UserMailer.new_user(user, current_user).deliver

			return { :success => true, :info => "User created successfully. Email has been sent." }
		end

		return { :success => false, :info => "Failed to create user." }
	end

	def delete_user(userId)
		if User.find(userId).destroy
			return { :success => true, :info => "User deleted successfully" }
		else
			return { :success => false, :info => "Failed to delete user." }
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