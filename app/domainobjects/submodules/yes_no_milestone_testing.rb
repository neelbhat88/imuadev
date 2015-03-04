class YesNoMilestoneTesting < CustomMilestone

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:TESTING]
    @submodule = Constants.SubModules[:YES_NO]

    @icon = "/assets/Testing.jpg"

    @title = "Testing Task"
    @milestone_description = "A generic milestone where you can type a custom testing goal. This milestone is manually completed by the user by clicking a checkbox."

  end

  def valid?
    return (
      super
    )
  end

end
