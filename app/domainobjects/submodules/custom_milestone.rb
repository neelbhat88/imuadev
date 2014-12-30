class CustomMilestone < ImuaMilestone

  def initialize(milestone=nil)
    super

    @title = "Custom"
    @description = "Custom goal:"
  end

end
