class Api::V1::SessionsController < Devise::SessionsController
	respond_to :json

	# POST /resource/sign_in
	def create
		logger.debug("******** Before sign in session previous url: #{session[:previous_url]}")
		self.resource = warden.authenticate!(auth_options)
		sign_in(resource_name, resource)
		yield resource if block_given?
		logger.debug("******** After sign in: #{session[:previous_url]}")

		cookies[:previous_url] = session[:previous_url]
		redirect_to app_path
	end

	def show_current_user
		reject_if_not_authorized_request!

		render status: 200,
			json: {
				success: true,
				info: "Current User",
				user: ViewUser.new(current_user, current_user.organization)
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
