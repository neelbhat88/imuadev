class MilestoneFactory
  def self.get_milestone(mod, submodule, milestone=nil)
    case submodule
    when Constants.SubModules[:ACADEMICS_GPA]
      return GpaMilestone.new(milestone)

    when Constants.SubModules[:SERVICE_HOURS]
      return HoursMilestone.new(milestone)
    when Constants.SubModules[:SERVICE_DEPTH_HOURS]
      return DepthHoursMilestone.new(milestone)

    when Constants.SubModules[:EXTRACURRICULAR_ACTIVITIES]
      return ActivitiesMilestone.new(milestone)
    when Constants.SubModules[:EXTRACURRICULAR_DEPTH_ACTIVITIES]
      return DepthActivitiesMilestone.new(milestone)
    when Constants.SubModules[:EXTRACURRICULAR_LEADERSHIP_ACTIVITIES]
      return LeadershipActivitiesMilestone.new(milestone)

    when Constants.SubModules[:TESTING_TAKE]
      return TakeTestMilestone.new(milestone)

    when Constants.SubModules[:YES_NO]
      if mod == Constants.Modules[:ACADEMICS]
        return YesNoMilestoneAcademics.new(milestone)
      elsif mod == Constants.Modules[:SERVICE]
        return YesNoMilestoneService.new(milestone)
      elsif mod == Constants.Modules[:EXTRACURRICULAR]
        return YesNoMilestoneExtracurricular.new(milestone)
      elsif mod == Constants.Modules[:COLLEGE_PREP]
        return YesNoMilestoneCollegePrep.new(milestone)
      elsif mod == Constants.Modules[:TESTING]
        return YesNoMilestoneTesting.new(milestone)
      # ONEGOAL_HACK START
      else
        custom = CustomMilestone.new(milestone)
        custom.module = mod
        custom.submodule = Constants.SubModules[:YES_NO]
        name = mod
        case mod
        when "2-year"
          custom.icon = "/assets/Academics.jpg"
        when "4-year"
          custom.icon = "/assets/Service.jpg"
        when "Assignments"
          custom.icon = "/assets/Extracurricular.jpg"
        when "Financial"
          custom.icon = "/assets/PDU.jpg"
        when "Campus_Connections"
          custom.icon = "/assets/Testing.jpg"
          name = "Campus Connections"
        end
        custom.milestone_description = "A generic milestone where you can type a custom #{name} goal. This milestone is manually completed by the user by clicking a checkbox."
        return custom
      # ONEGOAL_HACK END
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

  # ToDo: Remove this when code from progress_service.rb is removed
  # Keeping this around as an example for now
  def self.get_milestone_objects_TEMPORARY(milestones)
    milestone_objects = []
    milestones.each do | m |
      milestone_objects << MilestoneFactory.get_milestone(m[:module], m[:submodule], m)
    end

    return milestone_objects
  end
end
