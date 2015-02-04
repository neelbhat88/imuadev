class CustomFailure < Devise::FailureApp
  def redirect_url
    # Keep the ?pu query string on authentication failure - e.g. bad credentials
    login_path(:pu => params[:pu])
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
