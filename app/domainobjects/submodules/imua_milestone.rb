class ImuaMilestone
  attr_accessor :id, :title, :description, :value, :module, :submodule,
                  :importance, :points, :time_unit_id, :icon

  def self.Defaults
    return {
	  ID:			"",
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

  def initialize
	@id			  = ImuaMilestone.Defaults[:ID]
    @module       = ImuaMilestone.Defaults[:MODULE]
    @submodule    = ImuaMilestone.Defaults[:SUBMODULE]
    @title        = ImuaMilestone.Defaults[:TITLE]
    @description  = ImuaMilestone.Defaults[:DESCRIPTION]
    @value        = ImuaMilestone.Defaults[:VALUE]
    @time_unit_id = ImuaMilestone.Defaults[:TIME_UNIT_ID]
    @importance   = ImuaMilestone.Defaults[:IMPORTANCE]
    @points       = ImuaMilestone.Defaults[:POINTS]
    @icon         = ImuaMilestone.Defaults[:ICON]
  end

  def valid?
    return (
	  @id			!= ImuaMilestone.Defaults[:ID] &&
      @module       != ImuaMilestone.Defaults[:MODULE] &&
      @submodule    != ImuaMilestone.Defaults[:SUBMODULE] &&
      @title        != ImuaMilestone.Defaults[:TITLE] &&
      @description  != ImuaMilestone.Defaults[:DESCRIPTION] &&
      @value        != ImuaMilestone.Defaults[:VALUE] &&
      @time_unit_id != ImuaMilestone.Defaults[:TIME_UNIT_ID] &&
      @icon         != ImuaMilestone.Defaults[:ICON] &&
      @points.to_f   > 0
    )
  end

  def total_milestone_points(time_unit_id)

    time_units = RoadmapRepository.new.get_milestones_in_time_unit(time_unit_id)
    time_units = time_units.select {|tu| tu.submodule == @submodtype}
	
    totalPoints = 0
    time_units.each do | tu |
      totalPoints += tu.points
    end

    return totalPoints
  end

  def total_user_points(user_id, time_unit_id)
    #TODO: Log error
    return -1
  end
  
end
