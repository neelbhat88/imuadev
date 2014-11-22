class YesNoMilestoneTesting < ImuaMilestone

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:TESTING]
      @submodule = Constants.SubModules[:YES_NO]

      @title = "Testing Goal"
      @description = "Description:"
      @value = "Take Some Tests"
      @icon = "/assets/Testing.jpg"
    end

    @milestone_description = "A generic milestone where you can type a custom testing goal. This milestone is manually completed by the user by clicking a checkbox."

  end

  def has_earned?(user, time_unit_id)
    @earned = MilestoneService.new.has_user_earned_milestone?(user.id, time_unit_id, @id)
  end

  def valid?
    return (
      super
    )
  end

end
