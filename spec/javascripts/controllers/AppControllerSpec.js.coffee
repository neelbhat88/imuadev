describe "AppController", () ->
  $controller = null
  $rootScope = null
  CONSTANTS = null
  scope = null

  # Load the module
  beforeEach module "myApp"
  beforeEach inject (_$controller_, _$rootScope_, _CONSTANTS_) ->
    $controller = _$controller_
    $rootScope = _$rootScope_
    CONSTANTS = _CONSTANTS_

    scope = $rootScope.$new()
    $controller "AppController", {$scope: scope}

  describe "CONSTANTS", () ->
    it "are set on the scope", () ->
      expect(scope.CONSTANTS).toBeDefined()

    it "USER_ROLES constants are set correctly", () ->
      expect(scope.CONSTANTS.USER_ROLES.super_admin).toEqual(0)
      expect(scope.CONSTANTS.USER_ROLES.org_admin).toEqual(10)
      expect(scope.CONSTANTS.USER_ROLES.school_admin).toEqual(20)
      expect(scope.CONSTANTS.USER_ROLES.mentor).toEqual(40)
      expect(scope.CONSTANTS.USER_ROLES.student).toEqual(50)

    it "MODULES constants are set correctly", () ->
      expect(scope.CONSTANTS.MODULES.academics).toEqual("Academics")
      expect(scope.CONSTANTS.MODULES.service).toEqual("Service")
      expect(scope.CONSTANTS.MODULES.testing).toEqual("Testing")
      expect(scope.CONSTANTS.MODULES.extracurriculars).toEqual("Extracurricular")
      expect(scope.CONSTANTS.MODULES.college_prep).toEqual("College_Prep")
