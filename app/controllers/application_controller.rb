class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  after_filter :set_csrf_cookie_for_ng

  # Overries Devise after sign in
  def after_sign_in_path_for(resource)
    #return dashboard_path
  #   if current_user.super_admin?
  #     return super_admin_profile
  #   end

    return root_path
  end

  def authenticate_user
    authenticate_user!
  end

private

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified__request?
    super || form_authenticity_token == request.headers['HTTP_X_XSRF_TOKEN']
  end

end
