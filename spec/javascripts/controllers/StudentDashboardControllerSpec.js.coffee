xdescribe "StudentDashboardController", () ->
  # ************************
  # **** Instance Vars *****
  # ************************
  scope = null
  $controller = null
  $rootScope = null
  $q = null
  $httpBackend = null
  scope = null
  ProgressService = null
  OrganizaitonService = null
  CONSANTS = null

  # ************************
  # **** General Setup *****
  # ************************
  beforeEach module "myApp"
  beforeEach inject (_$controller_, _$rootScope_, _$q_, _CONSTANTS_, _$httpBackend_, _ProgressService_, _OrganizationService_) ->
    $controller = _$controller_
    $rootScope = _$rootScope_
    $q = _$q_
    $httpBackend = _$httpBackend_
    CONSTANTS = _CONSTANTS_

    ProgressService =
      getModulesProgress: () ->

    OrganizationService =
      getTimeUnits: () ->

    parentScope = $rootScope.$new()
    $controller "AppController", {$scope: parentScope}

    # Set up DashboardController since StudentDashboardController inherits from it
    user = {id: 1, first_name: "Neel", last_name: "Bhat", role: 50, organization_id: 10}
    dashboardScope = parentScope.$new()
    $controller "DashboardController", {$scope: dashboardScope, current_user: user}

    scope = dashboardScope.$new() # Creates a new scope that's a child of parentScope
  afterEach () ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  # ****************************
  # **** Actual test Setup *****
  # ****************************
  describe "on initialization", () ->
    beforeEach () ->
      getModulesDefer = $q.defer()
      getModulesDefer.resolve({hello: "world"}) # Don't really care what this returns for the test
      spyOn(ProgressService, 'getModulesProgress').and.returnValue(getModulesDefer.promise)

      spyOn(OrganizationService, 'getTimeUnits').and.callThrough()
      $httpBackend.when("GET", "/api/v1/organization/10/time_units").respond(200)

      $controller "StudentDashboardController", {$scope: scope, ProgressService: ProgressService}

    it "sets scope instance variables", () ->
      expect(scope.student.id).toEqual(1)
      expect(scope.student_with_modules_progress).toEqual(null)
      expect(scope.overall_points).toEqual({user: 0, total: 0, percent: 0})

    it "gets module progress from ProgressService", () ->
      scope.$apply(); #Call this to run watchers so that variables being set in callback functions
                      # get set
      expect(ProgressService.getModulesProgress).toHaveBeenCalled()
      expect(scope.student_with_modules_progress).toEqual({hello: "world"})

    it "Loads time units", () ->
      $httpBackend.flush()
      expect(OrganizationService.getTimeUnits).toHaveBeenCalled()
