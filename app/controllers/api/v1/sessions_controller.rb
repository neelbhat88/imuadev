class Api::V1::SessionsController < Devise::SessionsController
	respond_to :json

	# POST /resource/sign_in
	def create
		self.resource = warden.authenticate!(auth_options)
		sign_in(resource_name, resource)
		yield resource if block_given?

		# Set cookie with previous URL
		cookies[:previous_url] = session[:previous_url]

		Background.process do
	    Keen.publish("user_engagement", {
	                                      :user => current_user,
	                                      :day => DateTime.now.utc.beginning_of_day.iso8601,
	                                      :hour => DateTime.now.utc.beginning_of_hour.iso8601
	                                    }
	                )
	  end

		redirect_to app_path
	end

	def destroy
		sign_out current_user

		redirect_to login_path
	end

	def show_current_user
		status = :unauthorized
		user = nil

		if user_signed_in?
			status = :ok
			user = ViewUser.new(current_user, current_user.organization)
		end

		render status: status,
			json: {
				info: "Current User",
				user: user
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
