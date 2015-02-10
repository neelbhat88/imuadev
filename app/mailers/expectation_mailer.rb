class ExpectationMailer < ActionMailer::Base
  default from: "imua-notification@myimua.org"

  def changed_user_expectation(student, mentors, modifier, user_expectation, expectation)
    expectationStatus = Constants.ExpectationMailerStatus

    @student = student
    @modifier = modifier
    @status = expectationStatus[user_expectation.status]
    @expectation = expectation
    @comment = user_expectation.comment
    @user_expectation = user_expectation
    recipients = []

    mentors.each do |m|
      if m.id != modifier.id
        recipients << m.email
      end
    end

    mail(:to => recipients, :subject=>"Expectation: '#{expectation.title}' has been updated for #{student.full_name}")
  end

  def changed_user_expectation_to_student(student, modifier, user_expectation, expectation)
    expectationStatus = Constants.ExpectationMailerStatus

    @student = student
    @modifier = modifier
    @status = expectationStatus[user_expectation.status]
    @expectation = expectation
    @comment = user_expectation.comment
    @user_expectation = user_expectation

    mail(:to => student.email, :subject=>"Expectation: '#{expectation.title}' has been updated")
  end

end
