class MilestoneService

  def get_milestone_status(params)
    conditions = params

    milestoneQ = Querier.factory(Milestone).select([:id, :title, :description, :value, :module, :submodule, :points, :time_unit_id, :icon, :organization_id, :due_datetime]).where(conditions.slice(:milestone_id))
    conditions[:organization_id] = milestoneQ.pluck(:organization_id)
    conditions[:time_unit_id] = milestoneQ.pluck(:time_unit_id)

    userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name], [:organization_id]).where(conditions)
    userMilestoneQ = Querier.factory(UserMilestone).select([], [:user_id]).where(conditions)
    userQ.set_subQueriers([userMilestoneQ])

    organizationQ = Querier.factory(Organization).select([:name]).where(conditions.slice(:organization_id))
    timeUnitQ = Querier.factory(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
    organizationQ.set_subQueriers([userQ, timeUnitQ, milestoneQ])

    view = organizationQ.view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id].first.to_i)

    return ReturnObject.new(:ok, "Status for milestone_id: #{params[:milestone_id]}.", view)
  end

  def get_milestones(orgId, timeUnitId = nil, moduleTitle = nil)
    milestones = nil
    conditions = []
    arguments = {}

    conditions << 'organization_id = :organization_id'
    arguments[:organization_id] = orgId

    unless timeUnitId.nil?
      conditions << 'time_unit_id = :time_unit_id'
      arguments[:time_unit_id] = timeUnitId
    end

    unless moduleTitle.nil?
      conditions << 'module = :module'
      arguments[:module] = moduleTitle
    end

    allConditions = conditions.join(' AND ')
    milestones = Milestone.find(:all, :conditions => [allConditions, arguments])

    return milestones.map{|m| DomainMilestone.new(m)}
  end

  def create_milestone(ms)
    milestone = MilestoneFactory.get_milestone(ms[:module], ms[:submodule])

    milestone.value = ms[:value]
    milestone.points = ms[:points]
    milestone.time_unit_id = ms[:time_unit_id]
    milestone.organization_id = ms[:organization_id]

    if !milestone.valid?
    end

    newmilestone = Milestone.new do | m |
      m.module = milestone.module
      m.submodule = milestone.submodule
      m.title = milestone.title
      m.description = milestone.description
      m.value = milestone.value
      m.time_unit_id = milestone.time_unit_id
      m.importance = milestone.importance
      m.points = milestone.points
      m.icon = milestone.icon
      m.organization_id = milestone.organization_id
    end

    if newmilestone.save
      return ReturnObject.new(:ok, "Successfully created Milestone id: #{newmilestone.id}.", newmilestone)
    else
      return ReturnObject.new(:internal_server_error, newmilestone.errors, nil)
    end
  end

  def update_milestone(ms)
    milestone = Milestone.find(ms[:id])

    if !milestone.time_unit_id.nil? # Default milestones don't have a time_unit
      milestone.time_unit.milestones.each do | m |
        if m.id != ms[:id] && (m.module == ms[:module] && m.submodule == ms[:submodule] && m.value == ms[:value])
          return ReturnObject.new(:conflict, "A milestone of the same type and value already exists in #{milestone.time_unit.name}.", nil)
        end
      end
    end

    if milestone.update_attributes(:title => ms[:title],
                                    :description=>ms[:description],
                                    :points => ms[:points],
                                    :value => ms[:value])
      return ReturnObject.new(:ok, "Successfully updated Milestone id: #{milestone.id}.", milestone)
    end

    return ReturnObject.new(:internal_server_error, "Failed to update Milestone id: #{milestone.id}.", milestone)
  end

  def delete_milestone(milestoneId)
    if Milestone.find(milestoneId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Milestone id: #{milestoneId}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Milestone id: #{milestoneId}.", nil)
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

  def get_total_points(orgId)
    Milestone.where(:organization_id => orgId).sum(:points)
  end

  def get_user_milestones(userId)
    UserMilestone.where(:user_id => userId)
  end

end
