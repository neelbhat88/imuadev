class ProgressService

  # TODO: Fix front-end so that org_milestones and user_milestones can be
  #       filtered by module_title and still have the semester progress circle
  #       calculated accurately
  def get_user_progress(params)

    if params[:recalculate]
      get_recalculated_milestones(params[:user_id], params[:time_unit_id], params[:module])
    end

    query = {}
    query[:user] = UserQuerier.new.select([:role, :time_unit_id, :avatar], [:organization_id]).where(params.slice(:user_id))
    query[:user_milestone] = Querier.new(UserMilestone).where(params.except(:module))
    query[:user].set_sub_models(query[:user_milestone])
    
    params[:organization_id] = query[:user].domain.first[:organization_id].to_s

    query[:organization] = Querier.new(Organization).where(params.slice(:organization_id))
    query[:time_units] = Querier.new(TimeUnit).where(params.slice(:organization_id))
    query[:milestones] = Querier.new(Milestone).where(params.slice(:organization_id, :time_unit_id))
    query[:organization].set_sub_models(query[:user], query[:time_units], query[:milestones])

    view = query[:organization].view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(params[:organization_id])

    return ReturnObject.new(:ok, "Progress for user_id: #{params[:user_id]}, time_unit_id: #{params[:time_unit_id]}, module_title: #{params[:module]}.", view)
  end

  # TODO: Fix front-end so that org_milestones and user_milestones can be
  #       filtered by module_title and still have the semester progress circle
  #       calculated accurately
  def get_user_progress_2(params)

    if params[:recalculate]
      get_recalculated_milestones(params[:user_id], params[:time_unit_id], params[:module])
    end

    userOptions = {}
    attributes = [:organization_id, :role, :time_unit_id, :avatar]
    userOptions[:user] = User.find_by_filters2(params.slice(:user_id), attributes).first
    attributes = []
    userOptions[:user_milestones] = UserMilestone.find_by_filters(params.except(:module), attributes)
    viewUser = ViewUser2.new(userOptions)

    params[:organization_id] = userOptions[:user].organization_id

    orgOptions = {}
    attributes = []
    orgOptions[:organization] = Organization.find_by_filters(params.slice(:organization_id), attributes).first
    orgOptions[:time_units] = TimeUnit.find_by_filters(params.slice(:organization_id), attributes)
    orgOptions[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(params[:organization_id])
    orgOptions[:milestones] = Milestone.find_by_filters(params.slice(:organization_id, :time_unit_id), attributes)
    orgOptions[:users] = [viewUser]
    viewOrg = ViewOrganization2.new(orgOptions)

    return ReturnObject.new(:ok, "Progress for user_id: #{params[:user_id]}, time_unit_id: #{params[:time_unit_id]}, module_title: #{params[:module]}.", viewOrg)
  end

  def get_recalculated_milestones(user_id, time_unit_id, module_title)
    org_milestones = []
    user_milestones = []

    user = UserRepository.new.get_user(user_id)
    organization_id = user.organization_id

    # Get org Milestones based on the given parameters
    conditions = []
    arguments = {}

    conditions << 'organization_id = :organization_id'
    arguments[:organization_id] = organization_id

    unless time_unit_id.nil?
      conditions << 'time_unit_id = :time_unit_id'
      arguments[:time_unit_id] = time_unit_id
    end

    unless module_title.nil?
      conditions << 'module = :module'
      arguments[:module] = module_title
    end

    all_conditions = conditions.join(' AND ')
    org_milestones = Milestone.find(:all, :conditions => [all_conditions, arguments])

    # Get UserMilestones based on the given parameters
    conditions = []
    arguments = {}

    conditions << 'user_id = :user_id'
    arguments[:user_id] = user_id

    unless time_unit_id.nil?
      conditions << 'time_unit_id = :time_unit_id'
      arguments[:time_unit_id] = time_unit_id
    end

    unless module_title.nil?
      conditions << 'module = :module'
      arguments[:module] = module_title
    end

    all_conditions = conditions.join(' AND ')
    user_milestones = UserMilestone.find(:all, :conditions => [all_conditions, arguments])

    # Get all Milestones for given category and time_unit
    # Loop through and call has_earned? method
    # Add to UserMilestone if earned, Delete if not earned and user had previously earned the milestone

    # ToDo: We can probably filter out all the Yes/No milestones here and skip calling has_earned? on all Yes/No milestones
    # to save a DB call. Yes/No milestone are simple and we know they earned or lost based on checking/unchecking a checkbox so don't need to check again
    # here when saving other Academics data
    # For now this is fine, but if DB starts taking a hit we can save some calls here
    milestones = MilestoneFactory.get_milestone_objects(org_milestones)

    milestones.each do | m |
      # TODO - has_earned shouldn't depend on time_unit_id
      earned = m.has_earned?(user, time_unit_id)
      user_has_milestone = user_milestones.select{|um| um.milestone_id === m.id}.length > 0

      Rails.logger.debug "*****Milestone id: #{m.id}, value: #{m.value} earned? #{earned}"
      if earned and !user_has_milestone
        MilestoneService.new.add_user_milestone(user_id, time_unit_id, m.id)
        Rails.logger.debug "*****Milestone added to UserMilestone table"
      elsif !earned and user_has_milestone
        MilestoneService.new.delete_user_milestone(user_id, time_unit_id, m.id)
        Rails.logger.debug "*****Milestone deleted from UserMilestone table"
      end
    end

    return ReturnObject.new(:ok, "Recalculated milestones for user_id: #{user_id}, time_unit_id: #{time_unit_id}, module_title:#{module_title}.", milestones)
  end

end

class ModuleProgress
  attr_accessor :module_title, :time_unit_id, :points

  def initialize(title, time_unit_id, user_points, total_points)
    @module_title = title
    @time_unit_id = time_unit_id
    @points = {:user => user_points, :total => total_points}
  end

end
