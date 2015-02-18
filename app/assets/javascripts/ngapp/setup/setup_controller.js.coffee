angular.module('myApp')
.controller 'SetupController', ['$scope', '$modal', '$route', '$location', 'current_user', 'CONSTANTS', 'RoadmapService', 'OrganizationService', 'UsersService',
($scope, $modal, $route, $location, current_user, CONSTANTS, RoadmapService, OrganizationService, UsersService) ->
  $scope.current_user = current_user

  $scope.selected_widget = null
  $scope.selected_year = null
  $scope.selected_semester = null
  $scope.loading = true

  # Setup role specific stuff
  $scope.is_admin = (current_user.role <= CONSTANTS.USER_ROLES.org_admin)
  $scope.view_obj = {
    setup_widget_title: if $scope.is_admin then "Setup" else "Organization"
  }

  # TODO: Clean up this nav stuff - tried to make it nice but the mobile
  # and desktop views are too different for it to be nice. If we have a separate
  # mobile tmpl then it'll be easier since it'll organize the menu differently
  $scope.sub_nav_items = [
    {group: "Setup", title: "Organization Admins", widget: "admins" },
    {for_mentors: true, group: "Setup", title: "Student Expectations", widget: "expectations" },
    {group: "Setup", title: "Tests", widget: "tests" },
    # Used by mobile
    {for_mentors: true, group: "Roadmap", title: "Roadmap", widget: "roadmap"}
  ]

  $scope.nav_items_for_setup = () ->
    return $scope._.where($scope.sub_nav_items, {group: 'Setup'})

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

    selected_nav = $location.search().selected_nav # Reads query string
    selected_year = $location.search().year
    selected_sem = $location.search().semester
    if selected_nav
      $scope.selectWidget(selected_nav, {year: selected_year, semester: selected_sem})
    else
      if current_user.is_org_admin
        $scope.selectWidget("admins")
      else
        $scope.selectWidget("expectations")

    $scope.loading = false
  , (data) -> # Error

  $scope.selectWidget = (widget, opts={}) ->
    $scope.selected_widget = widget

    if widget == "roadmap"
      $scope.selected_year = opts.year
      $scope.selected_semester = opts.semester
    else
      $scope.selected_year = null
      $scope.selected_semester = null

    $location.search({selected_nav: widget, year: opts.year, semester: opts.semester}) #Sets query string param

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
