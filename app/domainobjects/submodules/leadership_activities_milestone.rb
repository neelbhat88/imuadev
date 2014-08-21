class LeadershipActivitiesMilestone < ImuaMilestone
  attr_accessor :target_leadership_activities

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:EXTRACURRICULAR]
      @submodule = Constants.SubModules[:EXTRACURRICULAR_LEADERSHIP_ACTIVITIES]

      @title = "Be a Leader"
      @description = "Minimum number of past leadership roles:"
      @value = "1"
      @icon = "/assets/Extracurricular.jpg"

      @target_leadership_activities = @value.to_i
    else
      @target_leadership_activities = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    user_leadership_activities = 0
    userExtracurricularActivityService = UserExtracurricularActivityService.new

    time_units = RoadmapRepository.new.get_time_units(user.organization_id)
    time_units.each do | tu |
      if tu.id <= time_unit_id.to_i
        details = userExtracurricularActivityService.get_user_extracurricular_activity_details(user.id, tu.id)
        details.each do | d |
          if !d.leadership.nil? && !d.leadership.empty?
            user_leadership_activities += 1
          end
        end
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
