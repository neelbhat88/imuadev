class YesNoMilestoneCollegePrep < CustomMilestone

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:COLLEGE_PREP]
    @submodule = Constants.SubModules[:YES_NO]

    @icon = "/assets/PDU.jpg"

    @title = "College Prep Task"
    @milestone_description = "A generic milestone where you can type a custom college prep goal. This milestone is manually completed by the user by clicking a checkbox."
  end

  def valid?
    return (
      super
    )
  end

end
