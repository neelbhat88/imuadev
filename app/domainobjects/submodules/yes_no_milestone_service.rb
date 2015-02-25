class YesNoMilestoneService < CustomMilestone

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:SERVICE]
    @submodule = Constants.SubModules[:YES_NO]

    @icon = "/assets/Service.jpg"

    @title = "Service Task"
    @milestone_description = "A generic milestone where you can type a custom service goal. This milestone is manually completed by the user by clicking a checkbox."
  end

  def has_earned?(user, time_unit_id)
    @earned = MilestoneService.new(nil).has_user_earned_milestone?(user.id, time_unit_id, @id)
  end

  def valid?
    return (
      super
    )
  end

end
