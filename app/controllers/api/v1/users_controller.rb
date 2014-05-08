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
	end

	# DELETE /users/:id
	def delete
	end

end