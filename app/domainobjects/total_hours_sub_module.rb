class TotalHoursSubModule

  attr_accessor :title, :default_milestone

  def initialize
    milestone = RoadmapRepository.new.get_default_milestone(
                                { :module => Constants.Modules[:SERVICE],
                                  :submodule => Constants.SubModules[:SERVICE_TOTAL_HOURS] } )

    @title = Constants.SubModules[:SERVICE_TOTAL_HOURS]
    @description = "The reason why this sub module is important"

    @default_milestone = ViewMilestone.new(milestone)
  end

end