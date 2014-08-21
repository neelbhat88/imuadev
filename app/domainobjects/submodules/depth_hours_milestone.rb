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

    organizations = UserServiceOrganizationService.new.get_user_service_organizations(user.id)
    _organizations_array = []
    organizations.each do | o |
      _organizations_array << {:organization => o, :depth_hours => 0}
    end

    time_units = RoadmapRepository.new.get_time_units(user.organization_id)
    time_units.each do | tu |
      if tu.id <= time_unit_id.to_i
        events = UserServiceOrganizationService.new.get_user_service_hours(user.id, tu.id)
        events.each do | e |
          _organizations_array.each do | o |
            if e.user_service_organization_id == o[:organization].id
              o[:depth_hours] += e.hours
              break
            end
          end
        end
      end
    end

    _organizations_array.each do | o |
      if o[:depth_hours] > max_user_depth_hours
        max_user_depth_hours = o[:depth_hours]
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
