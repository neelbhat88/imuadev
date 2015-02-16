class CustomMilestone < ImuaMilestone

  def initialize(milestone=nil)
    super

    @description = "Custom goal:"
  end

  def has_earned?(user, time_unit_id)
    @earned = MilestoneService.new.has_user_earned_milestone?(user.id, time_unit_id, @id)
  end

end
