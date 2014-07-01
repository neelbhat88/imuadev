class DepthHoursMilestone < ImuaMilestone
  attr_accessor :target_hours

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:SERVICE]
      @submodule = Constants.SubModules[:SERVICE_DEPTH_HOURS]

      @title = "Give Back"
      @description = "Community Service Hours:"
      @value = "10"
      @icon = "/assets/Service.jpg"

      @target_hours = @value.to_f
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

      @target_hours = milestone.value.to_f
    end
  end

  def valid?
    return (
      super && @value.to_f > 0
    )
  end

  def total_user_points(user_id, time_unit_id)
    return 0
  end

end
