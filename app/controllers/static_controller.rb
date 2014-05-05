class StaticController < ApplicationController
	before_filter :authenticate_user, except: [:index]

	# Set the layout based on if the user is signed in or not
	layout :choose_layout

  def index 
  	render "login"
  end

  def dashboard
  end

  def logout
  	# Reset session when user comes to login page
  	reset_session

  	redirect_to root_path
  end

  def choose_layout
  	user_signed_in? ? "angular" : "application"
  end
end