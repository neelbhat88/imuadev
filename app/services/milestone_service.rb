class MilestoneService

  #####################################
  ########### ORGANIZATION ############
  #####################################

  def get_org_milestone(orgMilestoneId)
    orgMilestone = OrgMilestone.find(orgMilestoneId)
    info = "OrgMilestone id: #{orgMilestone.id}."
    return ReturnObject.new(:ok, info, orgMilestone)
  end

  def get_org_milestones(orgId, timeUnitId = nil)
    orgMilestones = nil
    info = ""

    if timeUnitId.nil?
      orgMilestones = OrgMilestone.where(:organization_id => orgId)
      info = "All OrgMilestones for orgId: #{orgId}."
    else
      orgMilestones = OrgMilestone.where(:organization_id => orgId, :time_unit_id => timeUnitId)
      info = "All OrgMilestones for orgId: #{orgId}, timeUnitId: #{timeUnitId}."
    end

    return ReturnObject.new(:ok, info, orgMilestones)
  end

  def create_org_milestone(orgId, timeUnitId, orgMilestone)
    factoryOrgMilestone = MilestoneFactory.get_org_milestone(orgMilestone[:module], orgMilestone[:submodule])

    factoryOrgMilestone.value = orgMilestone[:value]
    factoryOrgMilestone.points = orgMilestone[:points]
    factoryOrgMilestone.time_unit_id = timeUnitId
    factoryOrgMilestone.organization_id = orgId

    newOrgMilestone = OrgMilestone.new do | m |
      m.module = factoryOrgMilestone.module
      m.submodule = factoryOrgMilestone.submodule
      m.title = factoryOrgMilestone.title
      m.description = factoryOrgMilestone.description
      m.value = factoryOrgMilestone.value
      m.time_unit_id = factoryOrgMilestone.time_unit_id
      m.importance = factoryOrgMilestone.importance
      m.points = factoryOrgMilestone.points
      m.icon = factoryOrgMilestone.icon
      m.organization_id = factoryOrgMilestone.organization_id
    end

    if !newOrgMilestone.valid?
    end

    if newOrgMilestone.save
      return ReturnObject.new(:ok, "Successfully created OrgMilestone id: #{newOrgMilestone.id}.", newOrgMilestone)
    end

    return ReturnObject.new(:internal_server_error, newOrgMilestone.errors.inspect, nil)
  end

  def update_org_milestone(orgMilestoneId, orgMilestone)
    dbOrgMilestone = get_org_milestone(orgMilestoneId).object

    if dbOrgMilestone.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find OrgMilestone with id: #{orgMilestoneId}.", nil)
    end

    if dbOrgMilestone.update_attributes(:title       => ms[:title],
                                        :description => ms[:description],
                                        :points      => ms[:points],
                                        :value       => ms[:value])
      return ReturnObject.new(:ok, "Successfully updated OrgMilestone id: #{dbOrgMilestone.id}.", dbOrgMilestone)
    end

    return ReturnObject.new(:internal_server_error, dbOrgMilestone.errors.inspect, dbOrgMilestone)
  end

  def delete_org_milestone(orgMilestoneId)
    dbOrgMilestone = get_org_milestone(orgMilestoneId).object

    if dbOrgMilestone.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find OrgMilestone with id: #{orgMilestoneId}.", nil)
    end

    if dbOrgMilestone.destroy()
      return ReturnObject.new(:ok, "Successfully deleted OrgMilestone id: #{dbOrgMilestone.id}.", nil)
    end

    return ReturnObject.new(:internal_server_error, dbOrgMilestone.errors.inspect, nil)
  end

  #################################
  ############# USER ##############
  #################################

  def get_user_milestone(userMilestoneId)
    userMilestone = UserMilestone.find(userMilestoneId)
    info = "UserMilestone id: #{userMilestone.id}."
    return ReturnObject.new(:ok, info, userMilestone)
  end

  def get_user_milestones(userId, timeUnitId = nil)
    userMilestones = nil
    info = ""

    if timeUnitId.nil?
      userMilestones = UserMilestone.where(:user_id => userId)
      info = "All UserMilestones for userId: #{userId}."
    else
      userMilestones = UserMilestone.where(:user_id => orgId, :time_unit_id => timeUnitId)
      info = "All UserMilestones for userId: #{orgId}, timeUnitId: #{timeUnitId}."
    end

    return ReturnObject.new(:ok, info, userMilestones)
  end

  def create_user_milestone(userId, orgMilestoneId)
    dbOrgMilestone = get_org_milestone(orgMilestoneId).object

    if dbOrgMilestone.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find OrgMilestone with id: #{orgMilestoneId}.", nil)
    end

    newUserMilestone = UserMilestone.new do | m |
      m.milestone_id = dbOrgMilestone.id
      m.time_unit_id = dbOrgMilestone.time_unit_id
      m.user_id      = userId
      m.module       = dbOrgMilestone.module
      m.submodule    = dbOrgMilestone.submodule
    end

    if !newUserMilestone.valid?
    end

    if newUserMilestone.save
      returnOrgMilestone = MilestoneFactory.get_org_milestone(dbOrgMilestone.module, dbOrgMilestone.submodule, dbOrgMilestone)
      returnOrgMilestone.earned = true
      return ReturnObject.new(:ok, "Successfully created UserMilestone id: #{newUserMilestone.id}", returnOrgMilestone)
    end

    return ReturnObject.new(:internal_server_error, newUserMilestone.errors.inspect, nil)
  end

  def delete_user_milestone(userMilestoneId)
    if UserMilestone.where(:user_id => userId, :milestone_id => milestone_id).destroy_all()
      return ReturnObject.new(:ok, "Successfully removed User Milestone", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to remove User Milestone", nil)
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



  def get_total_points(orgId)
    Milestone.where(:organization_id => orgId).sum(:points)
  end

  def get_all_user_milestones(userId)
    UserMilestone.where(:user_id => userId)
  end

  def get_user_and_org_milestones(userId, orgId, timeUnitId = nil)
    orgMilestones = nil
    userMilestones = nil
    info = ""

    if timeUnitId.nil?
      orgMilestones = OrgMilestone.where(:organization_id => orgId)
      userMilestones = UserMilestone.where(:user_id => userId)
      info = "All User and OrgMilestones for userId: #{userId}, orgId: #{orgId}."
    else
      orgMilestones = OrgMilestone.where(:organization_id => orgId, :time_unit_id => timeUnitId)
      userMilestones = UserMilestone.where(:user_id => userId, :time_unit_id => timeUnitId)
      info = "All User and OrgMilestones for userId: #{orgId}, orgId: #{orgId}, timeUnitId: #{timeUnitId}."
    end

    object = { :user_milestones => userMilestones, :org_milestones => orgMilestones }
    return ReturnObject.new(:ok, info, object)
  end

end
