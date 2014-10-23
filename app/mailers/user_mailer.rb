class UserMailer < ActionMailer::Base
	default :from => "imua-notification@myimua.org"

  def welcome(user, password)
  	@user = user
  	@password = password

  	mail(:to => user.email, :subject=>"Welcome to Imua!")
  end

  def new_user(user, created_by)
  	@user = user
  	@created_by = created_by

  	mail(:to => 'neel@hokuscholars.org', :subject=>"New User Created In Imua")
  end

  def log_error(error)
    @error = error

    mail(:to => 'neel@hokuscholars.org', :subject=>"Log Error in Imua #{ENV['ROOT_URL']}")
  end

	def reset_password(user, password)
		@user = user
		@password = password

		mail(:to => user.email, :subject => "Imua - Reset password request")
	end
end
