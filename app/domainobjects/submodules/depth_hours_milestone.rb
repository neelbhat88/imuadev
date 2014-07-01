class DepthHoursMilestone < ImuaMilestone
  attr_accessor :target_hours

  def initialize
    super

    @module = Constants.Modules[:SERVICE]
    @submodule = Constants.SubModules[:SERVICE_DEPTH_HOURS]

    @title = "Give Back"
    @description = "Community Service Hours:"
    @value = "10"
    @icon = "/assets/Service.jpg"
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
