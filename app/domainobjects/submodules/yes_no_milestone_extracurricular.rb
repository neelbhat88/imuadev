class YesNoMilestoneExtracurricular < CustomMilestone

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:EXTRACURRICULAR]
    @submodule = Constants.SubModules[:YES_NO]

    @icon = "/assets/Extracurricular.jpg"

    @title = "Extracurricular Task"
    @milestone_description = "A generic milestone where you can type a custom extracurricular goal. This milestone is manually completed by the user by clicking a checkbox."
  end

  def valid?
    return (
      super
    )
  end

end
