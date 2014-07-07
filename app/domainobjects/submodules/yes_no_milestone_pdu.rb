class YesNoMilestonePDU < ImuaMilestone

  def initialize(milestone=nil)
    super

    if milestone.nil?
      @module = Constants.Modules[:PDU]
      @submodule = Constants.SubModules[:YES_NO]

      @title = "Do It"
      @description = "Description:"
      @value = "Learn New Skills"
      @icon = "/assets/PDU.jpg"
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
