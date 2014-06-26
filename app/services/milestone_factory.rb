class MilestoneFactory
  def self.get_milestone(submodule)
    case submodule
    when Constants.SubModules[:ACADEMICS_GPA]
      return GpaMilestone.new
    when Constants.SubModules[:SERVICE_DEPTH_HOURS]
      return DepthHoursMilestone.new
    end
  end

end
