class YesNoMilestoneCollegePrep < CustomMilestone

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:COLLEGE_PREP]
    @submodule = Constants.SubModules[:YES_NO]

    @icon = "https://imuaproduction.s3.amazonaws.com/images/PDU.jpg"

    @title = "College Prep Task"
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
