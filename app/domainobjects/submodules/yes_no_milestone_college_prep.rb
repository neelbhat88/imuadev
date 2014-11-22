class YesNoMilestoneCollegePrep < ImuaMilestone

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:COLLEGE_PREP]
      @submodule = Constants.SubModules[:YES_NO]

      @title = "College Prep Goal"
      @description = "Description:"
      @value = "Learn New Skills"
      @icon = "/assets/PDU.jpg"
    end

    @milestone_description = "A generic milestone where you can type a custom college prep goal. This milestone is manually completed by the user by clicking a checkbox."
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
