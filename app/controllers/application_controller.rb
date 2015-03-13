class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :abilities, :can?

  before_filter :add_abilities
  before_filter :set_current_company
  before_filter :check_and_set_version_header

  respond_to :html # Without this, POST /sign_in fails - spent hours figuring this out..
                   # after_sign_in_path_for needs to return HTML since its rendering the view
  respond_to :json, :only => [:check_and_set_version_header]

  def student_can_access?(userId)
    if current_user.student? && current_user.id != userId
      return false
    end

    return true
  end

  def same_organization?(orgId)
    if !current_user.super_admin? && current_user.organization_id != orgId
      return false
    end

    return true
  end

  def authenticate_token
    user_email = request.headers["X-API-EMAIL"]
    user_auth_token = request.headers["X-API-TOKEN"]

    user = user_email && User.find_by_email(user_email)
    Rails.logger.debug("****** Authenticating token....")
    Rails.logger.debug("****** User #{user.email}....")
    Rails.logger.debug("****** Token #{user_auth_token}....")
    Rails.logger.debug("****** DB Token #{user.access_token.token_value}....")
    # We use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && user.access_token && Devise.secure_compare(user.access_token.token_value, user_auth_token)
      sign_in(user, store: false)
      Rails.logger.debug("********* Current User is #{current_user.email}")
    else
      render status: 401, json: {}
      return false
    end
  end

  protected

  def check_and_set_version_header
    @appVersion = AppVersionService.new.get_version_number.to_s
    response.headers['AppVersion'] = @appVersion

    # Only check the AppVersion if the header exists AND the user has a session
    if request.headers['AppVersion'] && user_signed_in? && request.headers['AppVersion'] != @appVersion
      Rails.logger.error("Error - AppVersion mismatch! - Current version: #{@appVersion}, Client's Version: #{request.headers['AppVersion']}. UserId: #{current_user.id}")
      render status: 426, json: {}
    end
  end

  def set_current_company
    if user_signed_in?
      @current_company = current_user.organization unless current_user.nil?
    end
  end

  def add_abilities
    abilities << Ability
  end

  def abilities
    @abilities ||= Six.new
  end

  # simple delegate method for controller & view
  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end

end
