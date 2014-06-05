class UserRepository
  def initialize
  end

  def get_user(userId)
    return User.find(userId)
  end

  def update_user_info(userObj)
    id = userObj[:id]
    first_name = userObj[:first_name]
    last_name = userObj[:last_name]
    phone = userObj[:phone]
    avatar = userObj[:avatar]

    user = User.find(id)

    if avatar == nil
      result = user.update_attributes(
                                  :first_name => first_name,
                                  :last_name => last_name,
                                  :phone => phone
                                )
    else
      result = user.update_attributes(
                                  :first_name => first_name,
                                  :last_name => last_name,
                                  :phone => phone,
                                  :avatar => avatar
                                )
    end

    if (result)
      new_user = get_user(id)

      return { :success => true, :info => "User info updated successfully!", :user => new_user }

    else
      old_user = get_user(id)

      return { :success => false, :info => user.errors.messages[:avatar], :user => old_user}
    end
  end

  def update_password(user_obj)
    id = user_obj[:id]
    current_password = user_obj[:current_password]
    password = user_obj[:password]
    password_confirmation = user_obj[:password_confirmation]

    user = User.find(id)

    if (user.update_with_password(user_obj))
      new_user = get_user(id)

      return { :success => true, :info => "Password updated successfully!", :user=>new_user }
    else
      old_user = get_user(id)

      return { :success => false, :info => user.errors.full_messages, :user=>old_user }
    end
  end

  def create_user(user_obj, current_user)
    if user_obj[:organization_id].nil? && user_obj[:role] != Constants.UserRole[:SUPER_ADMIN]
      return { :success => false, :info => "You must assign this user to an organization", :user => nil }
    elsif User.where(:email=> user_obj[:email]).length != 0
      return { :success => false, :info => "A user with the email #{user_obj[:email]} already exists.", :user => nil }
    end

    password = Devise.friendly_token.first(8)
    user = User.new do |u|
      u.email = user_obj[:email]
      u.first_name = user_obj[:first_name]
      u.last_name = user_obj[:last_name]
      u.role = user_obj[:role]
      u.organization_id = user_obj[:organization_id]
      u.password = password
    end

    if user.save
      UserMailer.welcome(user, password).deliver
      UserMailer.new_user(user, current_user).deliver

      return { :success => true, :info => "User created successfully. Email has been sent.", :user => user }
    end

    return { :success => false, :info => "Failed to create user.", :user => nil }
  end

  def delete_user(userId)
    if User.find(userId).destroy
      return { :success => true, :info => "User deleted successfully" }
    else
      return { :success => false, :info => "Failed to delete user." }
    end
  end
end