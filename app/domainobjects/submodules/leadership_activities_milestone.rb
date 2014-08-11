class LeadershipActivitiesMilestone < ImuaMilestone
  attr_accessor :target_leadership_activities

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:EXTRACURRICULAR]
      @submodule = Constants.SubModules[:EXTRACURRICULAR_LEADERSHIP_ACTIVITIES]

      @title = "Be a Leader"
      @description = "Number of activities with a leadership role:"
      @value = "1"
      @icon = "/assets/Extracurricular.jpg"

      @target_leadership_activities = @value.to_i
    else
      @target_leadership_activities = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    user_leadership_activities = 0

    events = UserExtracurricularActivityService.new.get_user_extracurricular_activity_events(user.id, time_unit_id)

    events.each do | e |
      if !e.leadership.nil? && !e.leadership.empty?
        user_leadership_activities += 1
      end
    end

    @earned = user_leadership_activities >= @target_leadership_activities
  end

  def valid?
    return (
      super && @target_leadership_activities > 0
    )
  end

end
