class ImuaMilestone
  attr_accessor :id, :title, :description, :value, :module, :submodule,
                  :importance, :points, :time_unit_id, :icon, :earned,
                  :organization_id, :milestone_description

  def self.Defaults
    return {
      ID:               "",
      MODULE:           "",
      SUBMODULE:        "",
      TITLE:            "n/a",
      DESCRIPTION:      "n/a",
      VALUE:            "n/a",
      TIME_UNIT_ID:     nil,
      ORGANIZATION_ID:  nil,
      IMPORTANCE:       1,
      POINTS:           10,
      ICON:             "n/a",
      EARNED:           false,
      VALUE:            ""
    }
  end

  def initialize(milestone = nil)
    if milestone.nil?
      @id               = ImuaMilestone.Defaults[:ID]
      @module           = ImuaMilestone.Defaults[:MODULE]
      @submodule        = ImuaMilestone.Defaults[:SUBMODULE]
      @title            = ImuaMilestone.Defaults[:TITLE]
      @description      = ImuaMilestone.Defaults[:DESCRIPTION]
      @value            = ImuaMilestone.Defaults[:VALUE]
      @time_unit_id     = ImuaMilestone.Defaults[:TIME_UNIT_ID]
      @importance       = ImuaMilestone.Defaults[:IMPORTANCE]
      @points           = ImuaMilestone.Defaults[:POINTS]
      @icon             = ImuaMilestone.Defaults[:ICON]
      @earned           = ImuaMilestone.Defaults[:EARNED]
      @organization_id  = ImuaMilestone.Defaults[:ORGANIZATION_ID]
    else
      @id               = milestone.id
      @module           = milestone.module
      @submodule        = milestone.submodule
      @title            = milestone.title
      @description      = milestone.description
      @value            = milestone.value
      @time_unit_id     = milestone.time_unit_id
      @importance       = milestone.importance
      @points           = milestone.points
      @icon             = milestone.icon
      @earned           = false
      @organization_id  = milestone.organization_id
    end
  end

  def valid?
    return (
      @id               != ImuaMilestone.Defaults[:ID] &&
      @module           != ImuaMilestone.Defaults[:MODULE] &&
      @submodule        != ImuaMilestone.Defaults[:SUBMODULE] &&
      @title            != ImuaMilestone.Defaults[:TITLE] &&
      @description      != ImuaMilestone.Defaults[:DESCRIPTION] &&
      @value            != ImuaMilestone.Defaults[:VALUE] &&
      @time_unit_id     != ImuaMilestone.Defaults[:TIME_UNIT_ID] &&
      @icon             != ImuaMilestone.Defaults[:ICON] &&
      @points           > 0 &&
      @organization_id  != ImuaMilestone.Defaults[:ORGANIZATION_ID]
    )
  end

end
