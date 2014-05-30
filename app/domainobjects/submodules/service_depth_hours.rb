class ServiceDepthHours

  attr_accessor :title, :default_milestone

  def initialize
    milestone = RoadmapRepository.new.get_default_milestone(
                                { :module => Constants.Modules[:SERVICE],
                                  :submodule => Constants.SubModules[:SERVICE_DEPTH_HOURS] } )

    @title = "Depth of Hours"
    @description = "The reason why this sub module is important"

    @default_milestone = ViewMilestone.new(milestone)
  end

end