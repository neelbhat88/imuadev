class DepthHoursMilestone < ImuaMilestone
  attr_accessor :target_hours

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:SERVICE]
      @submodule = Constants.SubModules[:SERVICE_DEPTH_HOURS]

      @title = "Service Hours"
      @description = "Community Service Hours:"
      @value = "10"
      @icon = "/assets/Service.jpg"

      @target_hours = @value.to_f
    else
      @target_hours = milestone.value.to_f
    end
  end

  def valid?
    return (
      super && @target_hours > 0
    )
  end

end
