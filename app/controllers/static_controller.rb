class StaticController < ApplicationController
  before_filter :authenticate_user, except: [:index, :forgot_password,
                                             :reset_password, :login,
                                             :reset_all_students_password]

  # Set the layout based on if the user is signed in or not
  layout :choose_layout

  def index
    render "index"
  end

  def login
    render "login"
  end

  def forgot_password
    render "forgot_password"
  end

  def reset_password
    email = params[:user][:email]

    if email == ""
      redirect_to forgot_password_path, :flash => { :error => "You must enter an email." }
      return
    end

    user = User.find_by_email(email)
    if user.nil?
      redirect_to forgot_password_path, :flash => { :error => "User does not exist." }
      return
    end

    UserRepository.new.reset_password(user)

    redirect_to forgot_password_path,
          :flash => { :success => "Check your email for your password reset instructions." }
  end

  # will require authentication when put into UI
  def reset_all_students_password
    Background.process do
      organization_id = params[:organization_id]
      users = User.where(:role => 50, :organization_id => organization_id)
      users.each do |u|
        new_password = UserRepository.new.generate_password()
        u.update_attributes(:password => new_password)
        UserMailer.reset_password(u, new_password).deliver
      end
    end
  end

  # will require authentication when put into UI
  def reset_users_password
    Background.process do
      user_ids = params[:user_ids] # changed pending route
      user_ids.each do |id|
        user = User.find(id)
        new_password = UserRepository.new.generate_password()
        user.update_attributes(:password => new_password)
        UserMailer.reset_password(user, new_password).deliver
      end
    end
  end


  def choose_layout
    user_signed_in? ? "angular" : "application"
  end
end
