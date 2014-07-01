class ImuaMilestone
  attr_accessor :id, :title, :description, :value, :module, :submodule,
                  :importance, :points, :time_unit_id, :icon

  def self.Defaults
    return {
      ID:           "",
      MODULE:       "",
      SUBMODULE:    "",
      TITLE:        "n/a",
      DESCRIPTION:  "n/a",
      VALUE:        "n/a",
      TIME_UNIT_ID: nil,
      IMPORTANCE:   1,
      POINTS:       10,
      ICON:         "n/a",
    }
  end

  def initialize(milestone = nil)
    if milestone.nil?
      @id           = ImuaMilestone.Defaults[:ID]
      @module       = ImuaMilestone.Defaults[:MODULE]
      @submodule    = ImuaMilestone.Defaults[:SUBMODULE]
      @title        = ImuaMilestone.Defaults[:TITLE]
      @description  = ImuaMilestone.Defaults[:DESCRIPTION]
      @value        = ImuaMilestone.Defaults[:VALUE]
      @time_unit_id = ImuaMilestone.Defaults[:TIME_UNIT_ID]
      @importance   = ImuaMilestone.Defaults[:IMPORTANCE]
      @points       = ImuaMilestone.Defaults[:POINTS]
      @icon         = ImuaMilestone.Defaults[:ICON]
    else
      @id           = milestone.id
      @module       = milestone.module
      @submodule    = milestone.submodule
      @title        = milestone.title
      @description  = milestone.description
      @value        = milestone.value
      @time_unit_id = milestone.time_unit_id
      @importance   = milestone.importance
      @points       = milestone.points
      @icon         = milestone.icon
    end
  end

  def valid?
    return (
      @id           != ImuaMilestone.Defaults[:ID] &&
      @module       != ImuaMilestone.Defaults[:MODULE] &&
      @submodule    != ImuaMilestone.Defaults[:SUBMODULE] &&
      @title        != ImuaMilestone.Defaults[:TITLE] &&
      @description  != ImuaMilestone.Defaults[:DESCRIPTION] &&
      @value        != ImuaMilestone.Defaults[:VALUE] &&
      @time_unit_id != ImuaMilestone.Defaults[:TIME_UNIT_ID] &&
      @icon         != ImuaMilestone.Defaults[:ICON] &&
      @points        > 0
    )
  end

end
