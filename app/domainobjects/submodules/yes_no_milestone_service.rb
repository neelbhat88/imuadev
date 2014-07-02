class YesNoMilestoneService < ImuaMilestone

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:SERVICE]
      @submodule = Constants.SubModules[:SERVICE_YES_NO]

      @title = "Do It"
      @description = "Description:"
      @value = "Do iiiiit"
      @icon = "/assets/Service.jpg"
    end

  end

  def has_earned?(user, time_unit_id)
    # TODO
    return false
  end

  def valid?
    return (
      super
    )
  end

end
