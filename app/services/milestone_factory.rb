class MilestoneFactory
  def self.get_milestone(submodule, milestone=nil)
    case submodule
    when Constants.SubModules[:ACADEMICS_GPA]
      return GpaMilestone.new(milestone)
    when Constants.SubModules[:SERVICE_DEPTH_HOURS]
      return DepthHoursMilestone.new(milestone)
    when Constants.SubModules[:ACADEMICS_YES_NO]
      return YesNoMilestoneAcademics.new(milestone)
    when Constants.SubModules[:SERVICE_YES_NO]
      return YesNoMilestoneService.new(milestone)
    end
  end

  def self.get_milestone_objects(milestones)
    milestone_objects = []
    milestones.each do | m |
      milestone_objects << MilestoneFactory.get_milestone(m.submodule, m)
    end

    return milestone_objects
  end
end
