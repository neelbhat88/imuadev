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
    super

    return true
  end
end
