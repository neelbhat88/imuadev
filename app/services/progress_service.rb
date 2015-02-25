class ProgressService

  def get_student_expectations(params)
    conditions = Marshal.load(Marshal.dump(params))

    userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :first_name, :last_name], [:organization_id]).where(conditions.slice(:user_id))
    conditions[:time_unit_id] = userQ.pluck(:time_unit_id)
    userMilestoneQ = Querier.factory(UserMilestone).select([:milestone_id, :module, :time_unit_id, :id], [:user_id]).where(conditions)
    userExpectationQ = Querier.factory(UserExpectation).select([:expectation_id, :status, :id, :comment, :updated_at, :modified_by_id, :modified_by_name], [:user_id]).where(conditions)

    conditions[:organization_id] = userQ.pluck(:organization_id).first
    organizationQ = Querier.factory(Organization).select([:name]).where(conditions.slice(:organization_id))
    timeUnitQ = Querier.factory(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
    milestoneQ = Querier.factory(Milestone).select([:id, :title, :description, :value, :module, :points, :time_unit_id, :due_datetime], [:organization_id]).where(conditions)
    expectationQ = Querier.factory(Expectation).select([:id, :title], [:organization_id]).where(conditions)

    if userExpectationQ.domain.length != expectationQ.domain.length
      # Update this to pass in @current_user when ProgressService is updated to
      # be initialized with current_user
      UserExpectationService.new(User.SystemUser).create_user_expectations(params[:user_id])
      userExpectationQ = nil
      userExpectationQ = Querier.factory(UserExpectation).select([:expectation_id, :status, :id, :comment, :updated_at, :modified_by_id, :modified_by_name], [:user_id]).where(conditions)
    end

    userQ.set_subQueriers([userMilestoneQ, userExpectationQ])
    organizationQ.set_subQueriers([userQ, timeUnitQ, milestoneQ, expectationQ])

    view = organizationQ.view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id].first.to_i)

    return ReturnObject.new(:ok, "Student expectations for user_id: #{params[:user_id]}.", view)
  end

  def get_student_dashboard(params)
    conditions = Marshal.load(Marshal.dump(params))

    userMilestoneQ = Querier.factory(UserMilestone).select([:milestone_id, :module, :time_unit_id, :id], [:user_id]).where(conditions)
    userExpectationQ = Querier.factory(UserExpectation).select([:expectation_id, :status, :id], [:user_id]).where(conditions)
    relationshipQ = Querier.factory(Relationship).select([:user_id, :assigned_to_id]).where(conditions)
    userAssignmentQ = Querier.factory(UserAssignment).select([:status, :id, :assignment_id], [:user_id]).where(conditions)

    conditions[:assignment_id] = userAssignmentQ.pluck(:assignment_id)
    assignmentQ = Querier.factory(Assignment).select([:title, :due_datetime, :description, :id, :user_id]).where(conditions.except(:user_id))

    conditions[:user_id] = (assignmentQ.pluck(:user_id) + relationshipQ.pluck(:assigned_to_id) << params[:user_id].to_s).uniq
    userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name, :sign_in_count, :current_sign_in_at], [:organization_id]).where(conditions.slice(:user_id))
    userQ.set_subQueriers([userMilestoneQ, userExpectationQ, relationshipQ, userAssignmentQ, assignmentQ])

    conditions[:organization_id] = userQ.pluck(:organization_id).first
    organizationQ = Querier.factory(Organization).select([:name]).where(conditions.slice(:organization_id))
    timeUnitQ = Querier.factory(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
    milestoneQ = Querier.factory(Milestone).select([:id, :title, :description, :value, :module, :points, :time_unit_id, :due_datetime, :submodule], [:organization_id]).where(conditions)
    expectationQ = Querier.factory(Expectation).select([:id, :title], [:organization_id]).where(conditions)
    organizationQ.set_subQueriers([userQ, timeUnitQ, milestoneQ, expectationQ])

    view = organizationQ.view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id].first.to_i)

    return ReturnObject.new(:ok, "Student dasboard for user_id: #{params[:user_id]}.", view)
  end

  # TODO: Fix front-end so that org_milestones and user_milestones can be
  #       filtered by module_title and still have the semester progress circle
  #       calculated accurately
  def get_user_progress(params)
    conditions = Marshal.load(Marshal.dump(params))

    if params[:recalculate]
      get_recalculated_milestones(params[:user_id], params[:time_unit_id], params[:module])
    end

    userQ = Querier.factory(User).select([:role, :time_unit_id, :avatar], [:organization_id]).where(conditions.slice(:user_id))
    userMilestoneQ = Querier.factory(UserMilestone).where(conditions.except(:module))
    userClassQ = Querier.factory(UserClass).select([:updated_at, :time_unit_id], [:user_id]).where(conditions)
    userExtracurricularActivityDetailQ = Querier.factory(UserExtracurricularActivityDetail).select([:updated_at, :time_unit_id], [:user_id]).where(conditions)
    userServiceHourQ = Querier.factory(UserServiceHour).select([:updated_at, :time_unit_id], [:user_id]).where(conditions)
    userTestQ = Querier.factory(UserTest).select([:updated_at, :time_unit_id], [:user_id]).where(conditions)
    userQ.set_subQueriers([userMilestoneQ, userClassQ, userExtracurricularActivityDetailQ,
      userServiceHourQ, userTestQ])

    conditions[:organization_id] = userQ.pluck(:organization_id).first

    organizationQ = Querier.factory(Organization).select([:name]).where(conditions.slice(:organization_id))
    timeUnitQ = Querier.factory(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
    milestoneQ = Querier.factory(Milestone).where(conditions.slice(:organization_id, :time_unit_id))
    organizationQ.set_subQueriers([userQ, timeUnitQ, milestoneQ])

    view = organizationQ.view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id].to_i)

    #ToDo: Super hacky but the Querier doesn't allow me to get the objects I need
    # ** This needs to be changed **
    # ** UPDATE: This won't work - the milestone object is not a DOT object but all the
    # **  milestone classes assume a DOT object
    #Rails.logger.debug("*********** Milestones: #{view[:milestones]}")
    #view[:milestones] = MilestoneFactory.get_milestone_objects_TEMPORARY(view[:milestones])

    return ReturnObject.new(:ok, "Progress for user_id: #{params[:user_id]}, time_unit_id: #{params[:time_unit_id]}, module_title: #{params[:module]}.", view)
  end

  def get_organization_progress(params)
    conditions = Marshal.load(Marshal.dump(params))

    userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :tag_list, :title, :first_name, :last_name, :sign_in_count, :current_sign_in_at], [:organization_id]).where(conditions)

    conditions[:user_id] = userQ.pluck(:id)

    userMilestoneQ = Querier.factory(UserMilestone).select([:milestone_id, :module, :time_unit_id], [:user_id]).where(conditions)
    relationshipQ = Querier.factory(Relationship).select([:user_id, :assigned_to_id]).where(conditions)
    userExpectationQ = Querier.factory(UserExpectation).select([:status], [:user_id]).where(conditions)
    userGpaQ = Querier.factory(UserGpa).select([:core_unweighted, :core_weighted, :regular_unweighted, :regular_weighted, :time_unit_id], [:user_id]).where(conditions)
    userExtracurricularActivityDetailQ = Querier.factory(UserExtracurricularActivityDetail).select([:time_unit_id], [:user_id]).where(conditions)
    userServiceHourQ = Querier.factory(UserServiceHour).select([:hours, :time_unit_id], [:user_id]).where(conditions)
    userTestQ = Querier.factory(UserTest).select([:time_unit_id], [:user_id]).where(conditions)
    userQ.set_subQueriers([userMilestoneQ, relationshipQ, userExpectationQ, userGpaQ, userExtracurricularActivityDetailQ, userServiceHourQ, userTestQ], :time_unit_id)

    organizationQ = Querier.factory(Organization).select([:name, :id]).where(conditions.slice(:organization_id))
    timeUnitQ = Querier.factory(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
    milestoneQ = Querier.factory(Milestone).select([:id, :module, :points, :time_unit_id, :due_datetime], [:organization_id]).where(conditions)
    organizationQ.set_subQueriers([userQ, timeUnitQ, milestoneQ])

    view = organizationQ.view.first
    view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id].to_i)

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
