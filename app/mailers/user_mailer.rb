class UserMailer < ActionMailer::Base
	default :from => "imua@hokuscholars.org"

  def welcome(user, password)
  	@user = user
  	@password = password

  	mail(:to => user.email, :subject=>"Welcome to Imua!")
  end
end
