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

		begin
			user = UserRepository.new.update_user_info(user)

			render status: 200,
			json: {
				success: true,
				info: "User info saved successfully.",
				user: user
			}

		rescue => e
			user = UserRepository.new.get_user(user[:id])

			refId = SecureRandom.uuid
			logger.error("Error: RefId: #{refId}. Exception: #{e.message}. Backtrace: #{e.backtrace}")

			render status: 200,
			json: {
				success: false,
				info: "Failed to save user info. Reference Id: #{refId}",
				user: user
			}

		end
	end

	# DELETE /users/:id
	def delete
	end

end

class UserRepository
	def initialize
	end

	def get_user(userId)
		return User.find(userId)
	end

	def update_user_info(user)
		User.find(user[:id])
			.update_attributes( :first_name => user[:first_name], 
													:last_name => user[:last_name],
													:phone => user[:phone] )
	end
end