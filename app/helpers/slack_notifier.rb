class SlackNotifier

  def initialize
    @web_hooks = {
      user_action_channel: "https://hooks.slack.com/services/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"
    }
  end

  def user_deleted(current_user, user)
    string = "User deleted: Org: #{user.organization.name}, Current user: #{current_user.id} - #{current_user.full_name}, Deleted user: #{user.full_name}"
    _notify(string, @web_hooks[:user_action_channel])
  end

  def user_created(current_user, user)
    string = "User created: Org: #{user.organization.name}, Current user: #{current_user.id} - #{current_user.full_name}, Created user: #{user.id} - #{user.full_name}, Role: #{user.role}"
    _notify(string, @web_hooks[:user_action_channel])
  end

  private

  def _notify(string, web_hook_url)
    if ENV["APP_ENV"] == "production"
      notifier = Slack::Notifier.new web_hook_url
      notifier.ping string
    end
  end

end
