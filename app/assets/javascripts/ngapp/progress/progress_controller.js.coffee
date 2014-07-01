angular.module('myApp')
.controller 'ProgressController', ['$scope', 'current_user', 'OrganizationService', 'ProgressService',
($scope, current_user, OrganizationService, ProgressService) ->
  $scope.selected_module = null
  $scope.semesters = []
  $scope.current_user = current_user
  $scope.selected_semester = null

  $(window).resize (event) ->
      setHeight()

  OrganizationService.getTimeUnits(current_user.organization_id)
    .success (data) ->
      $scope.semesters = []
      org_time_units = data.org_time_units

      # Set up each semester in descending order
      for tu in org_time_units
        $scope.semesters.unshift(tu)
        if tu.id == current_user.time_unit_id
          tu.name = "This Semester"
          break

      $scope.selected_semester = $scope.semesters[0]

  ProgressService.getModules(current_user, current_user.time_unit_id)
    .success (data) ->
      $scope.modules_progress = data.modules_progress
      $scope.selected_module = data.modules_progress[0]
      setHeight()

  $scope.selectModule = (mod) ->
    $scope.selected_module = mod

  $scope.selectSemester = (sem) ->
    ProgressService.getModules(current_user, sem.id)
      .success (data) ->
        $scope.modules_progress = data.modules_progress
        setHeight();

    $scope.selected_semester = sem

  $scope.getModuleTemplate = (modTitle) ->
    'progress/' + modTitle.toLowerCase() + '_progress.html' if modTitle

  setHeight = () ->
    windowHeight = $(window).outerHeight()
    headerHeight = $('header').outerHeight()
    circlesHeight = $('.js-modules-circles').outerHeight()
    bodyHeight = windowHeight - headerHeight - circlesHeight

    contentHeight = $('.js-module-data-content').outerHeight()

    if bodyHeight > contentHeight
      $('.js-module-data-content').outerHeight(bodyHeight + 'px')
      $('.js-module-data-side-nav').outerHeight(bodyHeight + 'px')
    else
      $('.js-module-data-side-nav').outerHeight(contentHeight + 'px')
]
