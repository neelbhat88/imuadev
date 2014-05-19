class Api::V1::SessionsController < Devise::SessionsController
	respond_to :json

	def show_current_user
		reject_if_not_authorized_request!

		render status: 200,
			json: {
				success: true,
				info: "Current User",
				user: ViewUser.new(current_user)
			}
	end

	def failure
		render status: 401,
			json: {
				success: false,
				info: "Unauthorized"
			}
	end

private
	def reject_if_not_authorized_request!
		warden.authenticate!(scope: resource_name,
			recall: "#{controller_path}#failure")
	end
end

class ViewUser
	attr_accessor :id, :email, :first_name, :last_name, :phone, :role, :avatar_url, :is_super_admin

	def initialize(user)
		@id = user.id
		@email = user.email
		@first_name = user.first_name
		@last_name = user.last_name
		@phone = user.phone
		@role = user.role
		@square_avatar_url = user.avatar.url(:square)

		@is_super_admin = user.super_admin?
	end
end