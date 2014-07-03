class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

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

end
