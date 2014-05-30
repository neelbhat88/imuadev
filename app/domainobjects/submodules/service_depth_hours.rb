class ServiceDepthHours

  attr_accessor :title, :default_milestone

  def initialize
    @title = "Depth of Hours"
    @description = "The reason why this sub module is important"

    milestone = RoadmapRepository.new.get_default_milestone(
                                { :module => Constants.Modules[:SERVICE],
                                  :submodule => Constants.SubModules[:SERVICE_DEPTH_HOURS] } )

    # Default milestone in case not found in DB
    if milestone.nil?
      milestone = Milestone.new
      milestone.is_default = true
      milestone.time_unit_id = nil
      milestone.module = Constants.Modules[:SERVICE]
      milestone.submodule = Constants.SubModules[:SERVICE_DEPTH_HOURS]
      milestone.importance = 2
      milestone.points = 10
      milestone.title = "Complete 10 hours of service for one organization"
      milestone.value = "10"
    end
    @default_milestone = ViewMilestone.new(milestone)
  end

end