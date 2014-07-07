class MilestoneFactory
  def self.get_milestone(mod, submodule, milestone=nil)
    case submodule
    when Constants.SubModules[:ACADEMICS_GPA]
      return GpaMilestone.new(milestone)

    when Constants.SubModules[:SERVICE_DEPTH_HOURS]
      return DepthHoursMilestone.new(milestone)

    when Constants.SubModules[:YES_NO]
      if mod == Constants.Modules[:ACADEMICS]
        return YesNoMilestoneAcademics.new(milestone)
      elsif mod == Constants.Modules[:SERVICE]
        return YesNoMilestoneService.new(milestone)
      end
    end

  end

  def self.get_milestone_objects(milestones)
    milestone_objects = []
    milestones.each do | m |
      milestone_objects << MilestoneFactory.get_milestone(m.module, m.submodule, m)
    end

    return milestone_objects
  end
end
