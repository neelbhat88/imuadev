class YesNoMilestoneTest < ImuaMilestone

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:TEST]
      @submodule = Constants.SubModules[:YES_NO]

      @title = "Do It"
      @description = "Description:"
      @value = "Take Some Tests"
      @icon = "/assets/Test.jpg"
    end

  end

  def has_earned?(user, time_unit_id)
    @earned = MilestoneService.new.has_user_earned_milestone?(user.id, time_unit_id, @id)
  end

  def valid?
    return (
      super
    )
  end

end
