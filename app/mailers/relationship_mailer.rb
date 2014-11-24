class RelationshipMailer < ActionMailer::Base
  default from: "imua-notification@myimua.org"

  def assigned_student_to_mentor(mentor, student)
    @mentor = mentor
    @student = student

    mail(:to => mentor.email, :subject=>"A new student is assigned to you")
  end

  def unassigned_student_from_mentor(mentor, student)
    @mentor = mentor
    @student = student

    mail(:to => mentor.email, :subject=>"A student is no longer assigned to you")
  end
end
