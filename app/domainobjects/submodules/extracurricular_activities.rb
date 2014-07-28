class ExtracurricularActivities < ImuaMilestone
  attr_accessor :target_hours

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:EXTRACURRICULAR]
      @submodule = Constants.SubModules[:EXTRACURRICULAR_ACTIVITIES]

      @title = "Extracurricular"
      @description = "Activities:"
      @value = "1"
      @icon = "/assets/Extracurricular.jpg"

      @target_activities = @value.to_f
    else
      @target_activities = milestone.value.to_f
    end
  end

  def has_earned?(user, time_unit_id)
    @earned = MilestoneService.new.has_user_earned_milestone?(user.id, time_unit_id, @id)
  end

  def valid?
    return (
      super && @target_hours > 0
    )
  end

end
