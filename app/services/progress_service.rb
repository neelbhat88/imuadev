class ProgressService

  # TODO: Fix front-end so that org_milestones and user_milestones can be
  #       filtered by module_title and still have the semester progress circle
  #       calculated accurately
  def get_user_progress(params)
    conditions = params

    if params[:recalculate]
      get_recalculated_milestones(params[:user_id], params[:time_unit_id], params[:module])
    end

    query = {}
    query[:user] = UserQuerier.new.select([:role, :time_unit_id, :avatar], [:organization_id]).where(conditions.slice(:user_id))
    query[:user_milestone] = Querier.new(UserMilestone).where(conditions.except(:module))
    query[:user].set_subQueriers([query[:user_milestone]])

    conditions[:organization_id] = query[:user].pluck(:organization_id)

    query[:organization] = Querier.new(Organization).where(conditions.slice(:organization_id))
    query[:time_units] = Querier.new(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
    query[:milestones] = Querier.new(Milestone).where(conditions.slice(:organization_id, :time_unit_id))
    query[:organization].set_subQueriers([query[:user], query[:time_units], query[:milestones]])

    view = query[:organization].view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id])

    return ReturnObject.new(:ok, "Progress for user_id: #{params[:user_id]}, time_unit_id: #{params[:time_unit_id]}, module_title: #{params[:module]}.", view)
  end

  def get_organization_progress(params)
    conditions = params
    query = {}

    query[:users] = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name, :sign_in_count, :current_sign_in_at], [:organization_id]).where(conditions)

    conditions[:user_id] = query[:users].pluck(:id)

    query[:user_milestones] = Querier.new(UserMilestone).select([:milestone_id, :module, :time_unit_id], [:user_id]).where(conditions)
    query[:relationships] = Querier.new(Relationship).select([:user_id, :assigned_to_id]).where(conditions)
    query[:user_expectations] = Querier.new(UserExpectation).select([:status], [:user_id]).where(conditions)
    query[:user_gpas] = Querier.new(UserGpa).select([:core_unweighted, :core_weighted, :regular_unweighted, :regular_weighted, :time_unit_id], [:user_id]).where(conditions)
    query[:user_extracurricular_activity_details] = Querier.new(UserExtracurricularActivityDetail).select([:time_unit_id], [:user_id]).where(conditions)
    query[:user_service_hours] = Querier.new(UserServiceHour).select([:hours, :time_unit_id], [:user_id]).where(conditions)
    query[:user_tests] = Querier.new(UserTest).select([:time_unit_id], [:user_id]).where(conditions)
    query[:users].set_subQueriers([query[:user_milestones], query[:relationships], query[:user_expectations], query[:user_gpas], query[:user_extracurricular_activity_details], query[:user_service_hours], query[:user_tests]], [:time_unit_id])

    query[:organization] = Querier.new(Organization).select([:name]).where(conditions.slice(:organization_id))
    query[:time_units] = Querier.new(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
    query[:milestones] = Querier.new(Milestone).select([:id, :module, :points, :time_unit_id], [:organization_id]).where(conditions)
    query[:organization].set_subQueriers([query[:users], query[:time_units], query[:milestones]])

    view = query[:organization].view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id])

    return ReturnObject.new(:ok, "Progress for organization_id: #{params[:organization_id]}.", view)
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
