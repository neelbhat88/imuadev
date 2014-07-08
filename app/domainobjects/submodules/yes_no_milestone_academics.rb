class YesNoMilestoneAcademics < ImuaMilestone

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:ACADEMICS]
      @submodule = Constants.SubModules[:YES_NO]

      @title = "Academic Goal"
      @description = "Description:"
      @value = "Good Grades"
      @icon = "/assets/Academics.jpg"
    end

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
