class HoursMilestone < ImuaMilestone
  attr_accessor :target_hours

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:SERVICE]
    @submodule = Constants.SubModules[:SERVICE_HOURS]
    @title = "Give Back"
    @description = "Minimum number of hours for this semester:"
    @milestone_description = "A milestone to set a minimum service hour requirement. This milestone is automatically triggered by the system when a user's total service hours equal or exceed the required amount."
    @icon = "https://imuaproduction.s3.amazonaws.com/images/Service.jpg"

    if milestone.nil?
      @target_hours = @value.to_i
    else
      @target_hours = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    user_hours = 0

    hours = UserServiceOrganizationService.new.get_user_service_hours(user.id, time_unit_id)

    hours.each do | h |
      user_hours += h.hours
    end

    @earned = user_hours >= @target_hours
  end

  def valid?
    return (
      super && @target_hours > 0
    )
  end

end
