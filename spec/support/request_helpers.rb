module RequestHelpers
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end

  module TokenHelper
    def get_with_token(path, params={}, headers={})
      create(:app_version)
      super_admin = create(:super_admin)

      # Signing in user in Devise to add to session for current_user
      @request.env["devise.mapping"] = Devise.mappings[:super_admin]
      sign_in :user, super_admin

      token = create(:access_token, user_id: super_admin.id)

      # headers.merge!('X-API-TOKEN' => token)
      # headers.merge!('X-API-EMAIL' => super_admin.email)
      @request.env["X-API-TOKEN"] = token.token_value
      @request.env["X-API-EMAIL"] = super_admin.email

      get path, params, headers
    end

    def super_admin_token
      create(:app_version)
      super_admin = create(:super_admin)

      # Signing in user in Devise to add to session for current_user
      @request.env["devise.mapping"] = Devise.mappings[:super_admin]
      sign_in :user, super_admin

      token = create(:access_token, user_id: super_admin.id)

      headers.merge!('X-API-TOKEN' => token)
      headers.merge!('X-API-EMAIL' => super_admin.email)
    end
  end


end
