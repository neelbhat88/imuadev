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
    super

    return true
  end
end
