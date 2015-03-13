class Api::V1::SessionsController < Devise::SessionsController
	respond_to :json

	# POST /user/sign_in
	# This is called when we log the user in with their
	# email and password AS WELL AS by the angular-devise
	# library when getting currentUser(). If not already
	# authenticated (e.g. on a hard refresh after it loses
	# any state) it will call this to re-authenticate.
	# This is why we check both token and credentials
	def create
    user_auth_token = request.headers["X-API-TOKEN"].presence
		email = params[:user][:email] || request.headers["X-API-EMAIL"].presence
		password = params[:user][:password]

		# TODO: Try and tell warden to not set session cookie
		# self.resource = warden.authenticate!(auth_options)
		# sign_in(resource_name, resource)
		# yield resource if block_given?

		Rails.logger.debug("****** Email #{email}")
		Rails.logger.debug("****** Token from request #{user_auth_token}")
		Rails.logger.debug("****** Current User is #{current_user.email} : #{current_user.first_name}") if current_user

		result = nil
		if password.nil?
			Rails.logger.debug("****** Token Authentication")
			result = authenticate_with_token({email: email, access_token: user_auth_token})
		else
			Rails.logger.debug("****** Credentials Authentication")
			result = authenticate_with_credentials({email: email, password: password})
		end

		Rails.logger.debug("********* Current User is #{current_user.email} : #{current_user.first_name}") if current_user
		Rails.logger.debug("********* After auth user's token is #{current_user.access_token.token_value}") if current_user && current_user.access_token

		if result[:status] == 200
			render status: 200,
				json: {
					user: ViewUser.new(current_user, current_user.organization),
					access_token: result[:access_token]
				}
		else
			render status: result[:status],
				json: {
					error: result[:error]
				}
		end
	end

	def destroy
		user_auth_token = request.headers["X-API-TOKEN"]
		email = request.headers["X-API-EMAIL"]

		#warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")

		user = email && User.find_by_email(email)
		Rails.logger.debug("********* Destroying user's access token: user - #{user.email}") if user

		if user.nil?
			render status: 401,
				json: {
					error: "Invalid token"
				}
			return
		end

		Rails.logger.debug("********* Destroying user's access token - #{user.access_token}")
		# Destroy user's access token
		user.access_token.destroy if user.access_token

		Rails.logger.debug("********* Destroyed user's access token - #{user.access_token}")
		Rails.logger.debug("********* Current User is #{current_user.email} : #{current_user.first_name}") if current_user

		sign_out

		Rails.logger.debug("********* Current User is #{current_user.email} : #{current_user.first_name}") if current_user

		render :status => 200,
					:json => { :success => true,
											:info => "Logged out"
										}
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

	def authenticate_with_credentials(args)
		email = args[:email]
		password = args[:password]

		user = User.find_by_email(email)

		Rails.logger.debug("******** #{email}")
		Rails.logger.debug("******** #{password}")
		if user.nil? || !user.valid_password?(password)
			return {status: 401, error: "Invalid email or password"}
		end

		sign_in(user, store: false)
		Rails.logger.debug("******** AFter devise sign_in")
		access_token = AccessTokenCreator.new.generate_token(user)
		Rails.logger.debug("******** New access token #{access_token}")
		Background.process do
	    Keen.publish("user_engagement", {
	                                      :user => current_user,
	                                      :day => DateTime.now.utc.beginning_of_day.iso8601,
	                                      :hour => DateTime.now.utc.beginning_of_hour.iso8601
	                                    }
	                )
	  end

		return {status: 200, access_token: access_token}
	end

	def authenticate_with_token(args)
		email = args[:email]
		token = args[:access_token]

		user = email && User.find_by_email(email)

    # We use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user.nil? || user.access_token.nil? || !Devise.secure_compare(user.access_token.token_value, token)
      return {status: 401, error: "Invalid token"}
    end

		sign_in(user, store: false)
		Rails.logger.debug("********* Current User is #{current_user.email}")
		#TODO: Look into why creating a new one every time we hit this doesn't work
		#access_token = AccessTokenCreator.new.generate_token(user)

		return {status: 200, access_token: token}

	end

end
