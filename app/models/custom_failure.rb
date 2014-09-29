class CustomFailure < Devise::FailureApp
  def redirect_url
    login_path
  end

  def respond
    # Had to do it this way because request.format for all requests
    # even AJAX requests were coming up as html for some reason
    json_request = request.accept.include? "application/json"

    if json_request
      self.status = 401
      self.content_type = 'json'
    else
      redirect
    end
  end
end