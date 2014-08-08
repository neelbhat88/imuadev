class HoursMilestone < ImuaMilestone
  attr_accessor :target_hours

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:SERVICE]
      @submodule = Constants.SubModules[:SERVICE_HOURS]

      @title = "Give Back"
      @description = "Community service hours:"
      @value = "10"
      @icon = "/assets/Service.jpg"

      @target_hours = @value.to_i
    else
      @target_hours = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    user_hours = 0

    events = UserServiceActivityService.new.get_user_service_activity_events(user.id, time_unit_id)

    events.each do | e |
      user_hours += e.hours
    end

    @earned = user_hours >= @target_hours
  end

  def valid?
    return (
      super && @target_hours > 0
    )
  end

end
