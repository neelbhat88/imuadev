class GpaMilestone < ImuaMilestone
  attr_accessor :target_gpa

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:ACADEMICS]
    @submodule = Constants.SubModules[:ACADEMICS_GPA]

    @title = "Good Grades"
    @description = "Minimum GPA:"
    @icon = "https://imuaproduction.s3.amazonaws.com/images/Academics.jpg"
    @milestone_description = "A milestone to set a minimum GPA requirement.
                              This milestone is automatically triggered
                              by the system when a user's GPA
                              equals or exceeds the GPA specified."

    if milestone.nil?
      @target_gpa = @value.to_f
    else
      @target_gpa = milestone.value.to_f
    end
  end

  def has_earned?(user, time_unit_id)
    if !UserGpaService.new.get_user_gpa(user.id, time_unit_id).nil?
      user_gpa = UserGpaService.new.get_user_gpa(user.id, time_unit_id).regular_unweighted
    else
      user_gpa = 0
    end
    Rails.logger.debug("****** User's GPA: #{user_gpa}. Target GPA: #{@target_gpa}")

    @earned = user_gpa >= @target_gpa
  end

  def valid?
    return (
      super && @target_gpa > 0 && @target_gpa < 5.0
    )
  end

end
