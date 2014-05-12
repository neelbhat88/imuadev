class UserMailer < ActionMailer::Base
	default :from => "imua@hokuscholars.org"

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
end
