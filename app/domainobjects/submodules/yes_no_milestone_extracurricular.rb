class YesNoMilestoneExtracurricular < CustomMilestone

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:EXTRACURRICULAR]
    @submodule = Constants.SubModules[:YES_NO]

    @icon = "https://imuaproduction.s3.amazonaws.com/images/Extracurricular.jpg"

    @title = "Extracurricular Task"
    @milestone_description = "A generic milestone where you can type a custom extracurricular goal. This milestone is manually completed by the user by clicking a checkbox."
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
