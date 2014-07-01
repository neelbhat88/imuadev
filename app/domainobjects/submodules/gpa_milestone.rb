class GpaMilestone < ImuaMilestone
  attr_accessor :target_gpa

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:ACADEMICS]
      @submodule = Constants.SubModules[:ACADEMICS_GPA]

      @title = "Good Grades"
      @description = "Minimum GPA:"
      @value = "3.5"
      @icon = "/assets/Academics.jpg"

      @target_gpa = @value.to_f
    else
      @id = milestone.id
      @module = milestone.module
      @submodule = milestone.submodule
      @title = milestone.title
      @description = milestone.description
      @value = milestone.value
      @icon = milestone.icon
      @time_unit_id = milestone.time_unit_id
      @importance = milestone.importance
      @points = milestone.points
      @icon = milestone.icon

      @target_gpa = milestone.value.to_f
    end
  end

  def has_earned?(user, time_unit_id)
    user_gpa = UserClassService.new.user_gpa(user.id, time_unit_id)
    Rails.logger.debug("****** User's GPA: #{user_gpa}. Target GPA: #{@target_gpa}")

    return user_gpa >= @target_gpa
  end

  def valid?
    return (
      super && @value.to_f > 0 && @value.to_f < 5.0
    )
  end

  def total_user_points(user_id, time_unit_id)
    return 0
  end

end
