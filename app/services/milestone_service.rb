class MilestoneService
  def create_milestone(ms)
    milestone = MilestoneFactory.get_milestone(ms[:module], ms[:submodule])

    milestone.value = ms[:value]
    milestone.points = ms[:points]
    milestone.time_unit_id = ms[:time_unit_id]

    if !milestone.valid?
    end

    newmilestone = Milestone.new do | m |
      m.module = milestone.module
      m.submodule = milestone.submodule
      m.title = milestone.title
      m.description = milestone.description
      m.value = milestone.value
      m.icon = milestone.icon
      m.time_unit_id = milestone.time_unit_id
      m.importance = milestone.importance
      m.points = milestone.points
      m.icon = milestone.icon
    end

    if newmilestone.save
      return ReturnObject.new(:ok, "Successfully created Milestone id: #{newmilestone.id}.", newmilestone)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create milestone.", nil)
    end
  end

  def has_user_earned_milestone?(userId, time_unit_id, milestone_id)
    return UserMilestone.where(:user_id => userId, :time_unit_id => time_unit_id, :milestone_id => milestone_id).length > 0
  end

  def yes_no_milestones_including_user(userId, module_title, time_unit_id)
    all_milestones = Milestone.where(:module => module_title, :submodule => Constants.SubModules[:YES_NO], :time_unit_id => time_unit_id)
    user_milestones = UserMilestone.where(:user_id => userId, :module => module_title, :submodule => Constants.SubModules[:YES_NO], :time_unit_id => time_unit_id)

    milestones = []
    all_milestones.each do | a |
      milestone = MilestoneFactory.get_milestone(a.module, a.submodule, a)

      if user_milestones.select{|u| u.milestone_id == a.id}.length > 0
        milestone.earned = true
      end

      milestones << milestone
    end

    return ReturnObject.new(:ok, "All YesNo milestones for #{module_title}", milestones)
  end

  def add_user_milestone(userId, time_unit_id, milestone_id)
    org_milestone = Milestone.find(milestone_id)

    user_milestone = UserMilestone.new do | um |
      um.milestone_id = org_milestone.id
      um.time_unit_id = time_unit_id
      um.user_id = userId
      um.module = org_milestone.module
      um.submodule = org_milestone.submodule
    end

    if user_milestone.save
      milestone = MilestoneFactory.get_milestone(org_milestone.module, org_milestone.submodule, org_milestone)
      milestone.earned = true

      return ReturnObject.new(:ok, "User Milestone added successfully", milestone)
    end

    return ReturnObject.new(:internal_server_error, "Failed to add User Milestone", nil)
  end

  def delete_user_milestone(userId, time_unit_id, milestone_id)
    if UserMilestone.where(:user_id => userId, :time_unit_id => time_unit_id, :milestone_id => milestone_id).destroy_all()
      return ReturnObject.new(:ok, "Successfully removed User Milestone", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to remove User Milestone", nil)
    end
  end

end
