class TaskMailer < ActionMailer::Base
  default :from => "imua-notification@myimua.org"

  def task_assigned(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task

    mail(:to => assignee.email, :subject=>"You have been assigned a new Task")
  end

  # def task_completed()
  #
  # end
end
