class GpaSubModule

  attr_accessor :title, :default_milestone

  def initialize
    milestone = RoadmapRepository.new.get_default_milestone(
                                { :module => Constants.Modules[:ACADEMICS],
                                  :submodule => Constants.SubModules[:ACADEMICS_GPA] } )

    @title = Constants.SubModules[:ACADEMICS_GPA]
    @description = "The reason why this sub module is important"

    @default_milestone = ViewMilestone.new(milestone)
  end

end