class ActivitiesMilestone < ImuaMilestone
  attr_accessor :target_activities

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:EXTRACURRICULAR]
      @submodule = Constants.SubModules[:EXTRACURRICULAR_ACTIVITIES]

      @title = "Get Involved"
      @description = "Minimum activities:"
      @value = "1"
      @icon = "/assets/Extracurricular.jpg"

      @target_activities = @value.to_i
    else
      @target_activities = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    user_activities = []

    activities = UserExtracurricularActivityService.new.get_user_extracurricular_activities(user.id, time_unit_id)
    events = UserExtracurricularActivityService.new.get_user_extracurricular_activity_events(user.id, time_unit_id)

    activities.each do | a |
      if events.select{|e| e.user_extracurricular_activity_id == a.id}.length > 0
        user_activities << a
      end
    end

    @earned = user_activities.length >= @target_activities
  end

  def valid?
    return (
      super && @target_activities > 0
    )
  end

end
