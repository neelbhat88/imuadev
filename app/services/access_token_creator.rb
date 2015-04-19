class AccessTokenCreator

  def generate_token(user)
    # Delete user's access token if it exists and generate a new one
    user.access_token.destroy if user.access_token

    token = _generate_unique_token

    access_token = AccessToken.new(user_id: user.id, token_value: token)

    if access_token.save
      return access_token.token_value
    else
      Rails.logger.error("Unable to create access token for User #{user.id}. Error #{access_token.errors.full_messages}")
      return nil
    end

  end

  private

  def _generate_unique_token
    loop do
      token = _generate_secure_token_string
      break token unless AccessToken.find_by_token_value(token)
    end
  end

  def _generate_secure_token_string
    SecureRandom.urlsafe_base64(25).tr('lIO0', 'sxyz')
  end

end
