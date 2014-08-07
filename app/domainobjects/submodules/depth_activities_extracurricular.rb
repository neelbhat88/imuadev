class DepthActivitiesMilestone < ImuaMilestone
  attr_accessor :target_depth_activities

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:EXTRACURRICULAR]
      @submodule = Constants.SubModules[:EXTRACURRICULAR_DEPTH_ACTIVITIES]

      @title = "Extracurricular"
      @description = "Depth Activities:"
      @value = "2"
      @icon = "/assets/Extracurricular.jpg"

      @target_depth_activities = @value.to_i
    else
      @target_depth_activities = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    max_user_depth_activities = 0

    activities = UserExtracurricularActivityService.new.get_user_extracurricular_activities(user.id)
    activities.each do | a |
      a.depth_activities = 0
    end

    time_units = RoadmapRepository.new.get_time_units(user.organization_id)
    time_units.each do | tu |
      if tu.id <= time_unit_id
        events = UserExtracurricularActivityService.new.get_user_extracurricular_activity_events(user.id, tu.id)
        activities.each do | a |
          # Check that we have at least one event for this activity in the time_unit
          if events.select{|e| e.user_extracurricular_activity_id == a.id}.length > 0
            a.depth_activities++
          end
        end
      end
    end

    activities.each do | a |
      if a.depth_activities > max_user_depth_activities
        max_user_depth_activities = a.depth_activities
      end
    end

    @earned = max_user_depth_activities >= @target_depth_activities
  end

  def valid?
    return (
      super && @target_depth_activities > 0
    )
  end

end
