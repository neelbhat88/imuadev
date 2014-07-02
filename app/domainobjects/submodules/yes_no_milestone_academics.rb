class YesNoMilestoneAcademics < ImuaMilestone

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:ACADEMICS]
      @submodule = Constants.SubModules[:ACADEMICS_YES_NO]

      @title = "Do It"
      @description = "Description:"
      @value = "Do iiiiit"
      @icon = "/assets/Academics.jpg"
    end

  end

  def has_earned?(user, time_unit_id)
    # TODO
    return false
  end

  def valid?
    return (
      super
    )
  end

end
