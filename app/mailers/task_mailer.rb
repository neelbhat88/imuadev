class TaskMailer < ActionMailer::Base
  default :from => "imua-notification@myimua.org"

  def task_assigned(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task

    mail(:to => assignee.email, :subject=>"You have been assigned a new Task")
  end

  def task_completed_by_assignee(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task

    mail(:to => assignor.email, :subject=>"A Task you assigned has been completed")
  end

  def task_completed_by_assignor(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task

    mail(:to => assignee.email, :subject=>"A Task assigned to you has been marked complete")
  end

  def task_incompleted_by_assignee(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task

    mail(:to => assignor.email, :subject=>"A Task you assigned has been marked incomplete")
  end

  def task_incompleted_by_assignor(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task

    mail(:to => assignee.email, :subject=>"A Task assigned to you has been marked incomplete")
  end

  def task_completed_by_other(current_user, assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @current_user = current_user
    @task = task

    mail(:to => assignor.email, :subject=>"A Task you assigned has been marked complete")
  end

  def task_incompleted_by_other(current_user, assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @current_user = current_user
    @task = task

    mail(:to => assignor.email, :subject=>"A Task you assigned has been marked incomplete")
  end
end
