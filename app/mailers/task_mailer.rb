class TaskMailer < ActionMailer::Base
  default :from => "imua-notification@myimua.org"

  def task_assigned(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task
    @user_assignment = get_user_assignment({user: assignee, task: task})

    mail(:to => assignee.email, :subject=>"You have been assigned a new Task")
  end

  def task_completed_by_assignee(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task
    @user_assignment = get_user_assignment({user: assignee, task: task})

    mail(:to => assignor.email, :subject=>"A Task you assigned has been completed")
  end

  def task_completed_by_assignor(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task
    @user_assignment = get_user_assignment({user: assignee, task: task})

    mail(:to => assignee.email, :subject=>"A Task assigned to you has been marked complete")
  end

  def task_incompleted_by_assignee(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task
    @user_assignment = get_user_assignment({user: assignee, task: task})

    mail(:to => assignor.email, :subject=>"A Task you assigned has been marked incomplete")
  end

  def task_incompleted_by_assignor(assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @task = task
    @user_assignment = get_user_assignment({user: assignee, task: task})

    mail(:to => assignee.email, :subject=>"A Task assigned to you has been marked incomplete")
  end

  def task_completed_by_other(current_user, assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @current_user = current_user
    @task = task
    @user_assignment = get_user_assignment({user: assignee, task: task})

    mail(:to => assignor.email, :subject=>"A Task you assigned has been marked complete")
  end

  def task_incompleted_by_other(current_user, assignee, assignor, task)
    @assignee = assignee
    @assignor = assignor
    @current_user = current_user
    @task = task
    @user_assignment = get_user_assignment({user: assignee, task: task})

    mail(:to => assignor.email, :subject=>"A Task you assigned has been marked incomplete")
  end

  def task_comment_added(args)
    @recipients = args[:recipients]
    @current_user = args[:current_user]
    @task = args[:task]
    @comment = args[:comment]
    @user_assignment = AssignmentService.new(User.SystemUser).get_user_assignment(@comment.commentable_id)

    emails = []
    @recipients.each do |r|
      emails << r.email
    end

    mail(:to => emails, :subject => "#{@current_user.full_name} commented on a Task you are involved with")
  end

  private

  def get_user_assignment(args)
    assignee = args[:user]
    task = args[:task]

    return AssignmentService.new(User.SystemUser).get_user_assignment_by_user_id_assignment_id({user_id: assignee.id, task_id: task.id})
  end
end
