class ServiceDepthHours

  attr_accessor :title, :default_milestone, :modtype, :submodtype

  def initialize
    @modtype = Constants.Modules[:SERVICE]
    @submodtype = Constants.SubModules[:SERVICE_DEPTH_HOURS]
    @title = "Depth of Hours"
    @description = "The reason why this sub module is important"

    milestone = RoadmapRepository.new.get_default_milestone(
                                { :module => @modtype,
                                  :submodule => @submodtype } )

    # Default milestone in case not found in DB
    if milestone.nil?
      milestone = Milestone.new
      milestone.is_default = true
      milestone.time_unit_id = nil
      milestone.module = @modtype
      milestone.submodule = @submodtype
      milestone.importance = 2
      milestone.points = 10
      milestone.title = "Give Back"
      milestone.description = "Community Service Hours:"
      milestone.value = "10"
      milestone.icon = "/assets/Service.jpg"
    end
    @default_milestone = ViewMilestone.new(milestone)
  end

  def total_milestone_points(time_unit_id)
    time_units = RoadmapRepository.new.get_milestones_in_time_unit(time_unit_id)
    time_units = time_units.select {|tu| tu.submodule == @submodtype}

    totalPoints = 0
    time_units.each do | tu |
      totalPoints += tu.points * tu.importance
    end

    return totalPoints
  end

  def total_user_points(user_id, time_unit_id)
    return 0
  end

end
