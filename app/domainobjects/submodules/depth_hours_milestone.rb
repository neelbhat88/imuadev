class DepthHoursMilestone < ImuaMilestone
  attr_accessor :target_hours

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:SERVICE]
      @submodule = Constants.SubModules[:SERVICE_DEPTH_HOURS]

      @title = "Service Hours"
      @description = "Community Service Hours:"
      @value = "10"
      @icon = "/assets/Service.jpg"

      @target_hours = @value.to_f
    else
      @target_hours = milestone.value.to_f
    end
  end

  def has_earned?(user, time_unit_id)
    @earned = MilestoneService.new.has_user_earned_milestone?(user.id, time_unit_id, @id)
  end

  def valid?
    return (
      super && @target_hours > 0
    )
  end

end
