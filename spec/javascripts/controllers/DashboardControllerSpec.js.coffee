xdescribe "DashboardController", () ->
  scope = null
  $controller = null
  $rootScope = null
  CONSTANTS = null
  scope = null
  $location = null

  # Load the module
  beforeEach module "myApp"
  beforeEach inject (_$controller_, _$rootScope_, _$location_, _CONSTANTS_) ->
    $controller = _$controller_
    $rootScope = _$rootScope_
    $location = _$location_
    CONSTANTS = _CONSTANTS_

    parentScope = $rootScope.$new()
    $controller "AppController", {$scope: parentScope}
    scope = parentScope.$new() # Creates a new scope that's a child of parentScope

  beforeEach () ->
    user = {id: 1, first_name: "first", last_name: "last", role: 50}
    $controller "DashboardController", {$scope: scope, current_user: user }

  it "sets scope instance variables", () ->
    expect(scope.current_user.id).toEqual(1)

  describe "loadDashboard()", () ->
    it "returns mentor dashboard", () ->
      dashboardTmpl = scope.loadDashboard(40)
      expect(dashboardTmpl).toEqual("dashboard/mentor_dashboard.html")

    it "returns student dashboard", () ->
      dashboardTmpl = scope.loadDashboard(50)
      expect(dashboardTmpl).toEqual("dashboard/student_dashboard.html")
