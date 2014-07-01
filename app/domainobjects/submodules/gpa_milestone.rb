class GpaMilestone < ImuaMilestone
  attr_accessor :target_gpa

  def initialize
    super

    @module = Constants.Modules[:ACADEMICS]
    @submodule = Constants.SubModules[:ACADEMICS_GPA]

    @title = "Good Grades"
    @description = "Minimum GPA:"
    @value = "3.5"
    @icon = "/assets/Academics.jpg"
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
