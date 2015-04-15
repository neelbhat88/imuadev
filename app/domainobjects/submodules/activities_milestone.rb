class ActivitiesMilestone < ImuaMilestone
  attr_accessor :target_activities

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:EXTRACURRICULAR]
    @submodule = Constants.SubModules[:EXTRACURRICULAR_ACTIVITIES]

    @title = "Get Involved"
    @description = "Minimum number of activities this semester:"
    @icon = "https://imuaproduction.s3.amazonaws.com/images/Extracurricular.jpg"
    @milestone_description = "A milestone to set a Extracurricular involvement
                              requirement. This milestone is automatically triggered
                              by the system when a user is involved in the number of
                              activities specified."

    if milestone.nil?
      @target_activities = @value.to_i
    else
      @target_activities = milestone.value.to_i
    end
  end

  def has_earned?(user, time_unit_id)
    user_activities = []

    activities = UserExtracurricularActivityService.new.get_user_extracurricular_activities(user.id)
    details = UserExtracurricularActivityService.new.get_user_extracurricular_activity_details(user.id, time_unit_id)

    activities.each do | a |
      if details.select{|d| d.user_extracurricular_activity_id == a.id}.length > 0
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
