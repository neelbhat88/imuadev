angular.module('myApp')
.controller 'SetupController', ['$scope', '$modal', '$route', 'current_user', 'RoadmapService', 'LoadingService', 'OrganizationService', 'UsersService',
($scope, $modal, $route, current_user, RoadmapService, LoadingService, OrganizationService, UsersService) ->
  $scope.current_user = current_user
  $scope.selected_widget = "admins"
  $scope.loading = true

  orgId = $route.current.params.id

  OrganizationService.getOrganizationWithRoadmap(orgId).then (data) ->
    $scope.organization = data.data.organization
    $scope.roadmap = data.data.roadmap

    $scope.roadmap.years = [
      {name: "Year 1", semesters: [{name: "Semester 1", semester: $scope.roadmap.time_units[0]}, {name: "Semester 2", semester: $scope.roadmap.time_units[1]}] },
      {name: "Year 2", semesters: [{name: "Semester 1", semester: $scope.roadmap.time_units[2]}, {name: "Semester 2", semester: $scope.roadmap.time_units[3]}] },
      {name: "Year 3", semesters: [{name: "Semester 1", semester: $scope.roadmap.time_units[4]}, {name: "Semester 2", semester: $scope.roadmap.time_units[5]}] },
      {name: "Year 4", semesters: [{name: "Semester 1", semester: $scope.roadmap.time_units[6]}, {name: "Semester 2", semester: $scope.roadmap.time_units[7]}] }
    ]

    $scope.loading = false
  , (data) -> # Error

  $scope.selectWidget = (widget) ->
    if $scope.selected_widget != widget
      $scope.selected_widget = widget

  $scope.getWidgetTemplate = (widgetTitle) ->
    'setup/widgets/widget_orgsetup_' + widgetTitle.toLowerCase() + '.html' if widgetTitle

]
