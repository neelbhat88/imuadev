angular.module('myApp')
.controller 'ProgressController', ['$scope', 'current_user', 'student', 'OrganizationService', 'ProgressService',
($scope, current_user, student, OrganizationService, ProgressService) ->
  $scope.selected_module = null
  $scope.semesters = []
  $scope.current_user = current_user
  $scope.student = student
  $scope.selected_semester = null

  $(window).resize (event) ->
      setHeight()

  OrganizationService.getTimeUnits(student.organization_id)
    .success (data) ->
      $scope.semesters = []
      org_time_units = data.org_time_units

      # Set up each semester in descending order
      for tu in org_time_units
        $scope.semesters.unshift(tu)
        if tu.id == student.time_unit_id
          tu.name = "This Semester"
          break

      $scope.selected_semester = $scope.semesters[0]

  ProgressService.getModules(student, student.time_unit_id)
    .success (data) ->
      $scope.modules_progress = data.modules_progress
      $scope.selected_module = data.modules_progress[0]
      setHeight()

  $scope.$watch 'selected_semester', () ->
    ProgressService.yesNoMilestones($scope.current_user, $scope.selected_semester.id, $scope.selected_module.module_title)
      .success (data) ->
        $scope.yes_no_milestones = data.yes_no_milestones

  $scope.toggleYesNoMilestone = (milestone) ->
    if milestone.earned
      ProgressService.addUserMilestone($scope.current_user, $scope.selected_semester.id, milestone.id)
        .success (data) ->
          refreshPoints()
    else
      ProgressService.deleteUserMilestone($scope.current_user, $scope.selected_semester.id, milestone.id)
        .success (data) ->
          refreshPoints()

  refreshPoints = () ->
    # ToDo: Might be better to broadcast something here that progresscontroller lisents for and then updates progress accordingly
    ProgressService.progressForModule($scope.current_user, $scope.selected_semester.id, $scope.selected_module.module_title)
      .success (data) ->
        for mod in $scope.modules_progress # Loop through modules on progress controller
          if mod.module_title == data.module_progress.module_title
            mod.points = data.module_progress.points

  $scope.selectModule = (mod) ->
    $scope.selected_module = mod

  $scope.selectSemester = (sem) ->
    ProgressService.getModules(student, sem.id)
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
