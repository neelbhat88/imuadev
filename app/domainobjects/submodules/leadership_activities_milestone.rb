class LeadershipActivitiesMilestone < ImuaMilestone
  attr_accessor :target_leadership_activities

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:EXTRACURRICULAR]
    @submodule = Constants.SubModules[:EXTRACURRICULAR_LEADERSHIP_ACTIVITIES]

    @title = "Be a Leader"
    @description = "Minimum number of past leadership roles:"
    @icon = "https://imuaproduction.s3.amazonaws.com/images/Extracurricular.jpg"

    @milestone_description = "A milestone to set a requirement to hold a leadership position in an Extracurricular for a specified number of semesters. This milestone is automatically triggered by the system when a user's leadership roles across all of their Extracurricular Activities in the past equals or exceeds the number specified."

    if milestone.nil?
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
