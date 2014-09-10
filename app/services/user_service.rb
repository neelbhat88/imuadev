class UserService

  def initialize
  end

  # TODO: Fix front-end so that org_milestones and user_milestones can be
  #       filtered by module_title and still have the semester progress circle
  #       calculated accurately
  def get_user_progress(userId, timeUnitId = nil, moduleTitle = nil)
    user = User.find(userId)

    userOptions = {}
    userOptions[:user_milestones] = MilestoneService.new.get_user_milestones_2(userId, timeUnitId)
    userOptions[:user_classes] = UserClassService.new.get_user_classes_2(userId, timeUnitId, moduleTitle)
    userOptions[:user_service_hours] = UserServiceOrganizationService.new.get_user_service_hours_2(userId, timeUnitId, moduleTitle)
    userOptions[:user_extracurricular_activity_details] = UserExtracurricularActivityService.new.get_user_extracurricular_activity_details_2(userId, timeUnitId, moduleTitle)
    userOptions[:user_tests] = TestService.new.get_user_tests_2(userId, timeUnitId, moduleTitle)

    domainUser = DomainUser.new(user, userOptions)

    orgId = user.organization_id
    org = Organization.find(orgId)

    orgOptions = {}
    orgOptions[:time_units] = OrganizationService.new.get_time_units(orgId)
    orgOptions[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(orgId)
    orgOptions[:milestones] = MilestoneService.new.get_milestones(orgId, timeUnitId)
    # orgOptions[:expectations] = ExpectationService.new.get_expectations(orgId)
    # orgOptions[:org_tests] = TestService.new.get_org_tests(orgId)
    orgOptions[:users] = [domainUser]

    domainOrg = DomainOrganization.new(org, orgOptions)

    return ReturnObject.new(:ok, "Progress for userId: #{userId}, timeUnitId: #{timeUnitId}, moduleTitle: #{moduleTitle}.", domainOrg)
  end

end # class UserService
