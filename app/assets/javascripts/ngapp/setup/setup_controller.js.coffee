angular.module('myApp')
.controller 'SetupController', ['$scope', '$modal', '$route', 'current_user', 'RoadmapService', 'LoadingService', 'OrganizationService', 'UsersService',
($scope, $modal, $route, current_user, RoadmapService, LoadingService, OrganizationService, UsersService) ->
  $scope.current_user = current_user
  if current_user.is_org_admin
    $scope.selected_widget = "admins"
  else
    $scope.selected_widget = "expectations"

  $scope.selected_year = null
  $scope.selected_semester = null
  $scope.loading = true

  orgId = $route.current.params.id

  RoadmapService.getEnabledModules(orgId)
    .success (data) -> # Success
      $scope.enabled_modules = data.enabled_modules

  OrganizationService.getOrganizationWithRoadmap(orgId).then (data) ->
    $scope.organization = data.data.organization
    $scope.roadmap = data.data.roadmap

    $scope.roadmap.years = [
      {name: "Year 1", id: 1, semesters: [
        {name: "Semester 1", id: 1, semester: $scope.roadmap.time_units[0]},
        {name: "Semester 2", id: 2, semester: $scope.roadmap.time_units[1]}
      ]},
      {name: "Year 2", id: 2, semesters: [
        {name: "Semester 1", id: 1, semester: $scope.roadmap.time_units[2]},
        {name: "Semester 2", id: 2, semester: $scope.roadmap.time_units[3]}
      ]},
      {name: "Year 3", id: 3, semesters: [
        {name: "Semester 1", id: 1, semester: $scope.roadmap.time_units[4]},
        {name: "Semester 2", id: 2, semester: $scope.roadmap.time_units[5]}
      ]},
      {name: "Year 4", id: 4, semesters: [
        {name: "Semester 1", id: 1, semester: $scope.roadmap.time_units[6]},
        {name: "Semester 2", id: 2, semester: $scope.roadmap.time_units[7]}
      ]}
    ]

    $scope.loading = false
  , (data) -> # Error

  $scope.selectWidget = (widget) ->
    if $scope.selected_widget != widget
      $scope.selected_widget = widget
      $scope.selected_year = null
      $scope.selected_semester = null

  $scope.selectRoadmap = (year, semester) ->
    if year != null
      $scope.selected_year = year
    if semester != null
      $scope.selected_semester = semester
    $scope.selected_widget = "roadmap"

  $scope.getWidgetTemplate = (widgetTitle) ->
    'setup/widgets/orgsetup_' + widgetTitle.toLowerCase() + '.html' if widgetTitle

  $scope.addOrgAdmin = () ->
    modalInstance = $modal.open
      templateUrl: 'organization/add_user_modal.html',
      controller: 'AddUserModalController',
      backdrop: 'static',
      size: 'sm',
      resolve:
        current_user: () -> $scope.current_user
        organization: () -> $scope.organization
        new_user: () -> UsersService.newOrgAdmin($scope.organization.id)

    modalInstance.result.then (user) ->
      $scope.organization.orgAdmins.push(user)

]
