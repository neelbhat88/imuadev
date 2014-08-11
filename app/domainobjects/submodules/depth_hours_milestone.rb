class DepthHoursMilestone < ImuaMilestone
  attr_accessor :target_depth_hours

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:SERVICE]
      @submodule = Constants.SubModules[:SERVICE_DEPTH_HOURS]

      @title = "Be Committed"
      @description = "Minimum service hours for a single organization:"
      @value = "10"
      @icon = "/assets/Service.jpg"

      @target_depth_hours = @value.to_i
    else
      @target_depth_hours = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    max_user_depth_hours = 0

    activities = UserServiceActivityService.new.get_user_service_activities(user.id)
    _activities_array = []
    activities.each do | a |
      _activities_array << {:activity => a, :depth_hours => 0}
    end

    time_units = RoadmapRepository.new.get_time_units(user.organization_id)
    time_units.each do | tu |
      if tu.id <= time_unit_id.to_i
        events = UserServiceActivityService.new.get_user_service_activity_events(user.id, tu.id)
        events.each do | e |
          _activities_array.each do | a |
            if e.user_service_activity_id == a[:activity].id
              a[:depth_hours] += e.hours
              break
            end
          end
        end
      end
    end

    _activities_array.each do | a |
      if a[:depth_hours] > max_user_depth_hours
        max_user_depth_hours = a[:depth_hours]
      end
    end

    @earned = max_user_depth_hours >= @target_depth_hours
  end

  def valid?
    return (
      super && @target_hours > 0
    )
  end

end
