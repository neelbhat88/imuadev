class AcademicsGpa

  attr_accessor :title, :default_milestone

  def initialize
    @title = "GPA"
    @description = "The reason why this sub module is important"

    milestone = RoadmapRepository.new.get_default_milestone(
                                { :module => Constants.Modules[:ACADEMICS],
                                  :submodule => Constants.SubModules[:ACADEMICS_GPA] } )

    # Default milestone in case not found in DB
    if milestone.nil?
      milestone = Milestone.new
      milestone.is_default = true
      milestone.time_unit_id = nil
      milestone.module = Constants.Modules[:ACADEMICS]
      milestone.submodule = Constants.SubModules[:ACADEMICS_GPA]
      milestone.importance = 2
      milestone.points = 10
      milestone.title = "Keep your overall GPA over a 3.5"
      milestone.value = "3.5"
    end
    @default_milestone = ViewMilestone.new(milestone)
  end

end