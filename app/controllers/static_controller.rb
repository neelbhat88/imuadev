class StaticController < ApplicationController
  before_filter :authenticate_user, except: [:index, :forgot_password,
                                             :reset_password, :login]

  # Set the layout based on if the user is signed in or not
  layout :choose_layout

  def index
    render "index"
  end

  def login
    if params[:expired] == "true"
      flash.now[:alert] = "Your session has expired. Please log in again."
    end

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

  def choose_layout
    user_signed_in? ? "angular" : "application"
  end
end
