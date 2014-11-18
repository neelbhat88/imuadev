class ExpectationMailer < ActionMailer::Base
  default from: "imua-notification@myimua.org"

  def changed_user_expectation(student, mentors, modifier, user_expectation, expectation)
    expectationStatus = ['Meeting', 'Needs Work', 'Not Meeting']

    @student = student
    @modifier = modifier
    @status = expectationStatus[user_expectation.status]
    @expectation = expectation
    @comment = user_expectation.comment
    recipients = [student.email]

    mentors.each do |m|
      if m.id != modifier.id
        recipients << m.email
      end
    end

    mail(:to => recipients, :subject=>"Expectation: '#{expectation.title}' has been updated for #{student.full_name}")
  end

end
