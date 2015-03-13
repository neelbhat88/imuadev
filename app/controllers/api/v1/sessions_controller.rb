class Api::V1::SessionsController < Devise::SessionsController
	respond_to :json
	skip_before_filter :verify_authenticity_token
	
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

		result = nil
		if password.nil?
			result = authenticate_with_token({email: email, access_token: user_auth_token})
		else
			result = authenticate_with_credentials({email: email, password: password})
		end

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

		user = email && User.find_by_email(email)

		if user.nil?
			render status: 401,
				json: {
					error: "Invalid token"
				}
			return
		end

		# Destroy user's access token
		user.access_token.destroy if user.access_token

		sign_out

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

		if user.nil? || !user.valid_password?(password)
			return {status: 401, error: "Invalid email or password"}
		end

		sign_in(user, store: false)

		access_token = AccessTokenCreator.new.generate_token(user)

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

		#TODO: Look into why creating a new one every time we hit this doesn't work
		#access_token = AccessTokenCreator.new.generate_token(user)

		return {status: 200, access_token: token}

	end

end
