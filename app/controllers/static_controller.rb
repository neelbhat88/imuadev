class StaticController < ApplicationController
  before_filter :authenticate_user, except: [:app, :index, :forgot_password,
                                             :reset_password, :login]

  def index
    render "index"
  end

  def app
    render "app", layout: "angular"
  end

  def login
    if user_signed_in?
      sign_out current_user
    end

    session[:previous_url] = params[:pu]
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

end
