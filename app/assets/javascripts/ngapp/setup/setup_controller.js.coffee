angular.module('myApp')
.controller 'SetupController', ['$scope', '$modal', '$route', 'current_user', 'RoadmapService', 'LoadingService', 'OrganizationService', 'UsersService',
($scope, $modal, $route, current_user, RoadmapService, LoadingService, OrganizationService, UsersService) ->
  $scope.current_user = current_user
  $scope.selected_widget = "admins"
  $scope.loading = true

  orgId = $route.current.params.id

  OrganizationService.getOrganizationWithRoadmap(orgId).then (data) ->
    $scope.organization = data.data.organization
    $scope.loading = false
  , (data) -> # Error

  $scope.selectWidget = (widget) ->
    if $scope.selected_widget != widget
      $scope.selected_widget = widget

  $scope.getWidgetTemplate = (widgetTitle) ->
    'setup/widgets/widget_orgsetup_' + widgetTitle.toLowerCase() + '.html' if widgetTitle

]
