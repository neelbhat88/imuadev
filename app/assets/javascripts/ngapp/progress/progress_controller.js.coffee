angular.module('myApp')
.controller 'ProgressController', ['$route', '$scope', 'current_user', 'student', 'OrganizationService', 'ProgressService',
($route, $scope, current_user, student, OrganizationService, ProgressService) ->
  $scope.modules_progress = []
  $scope.selected_module = null
  $scope.semesters = []
  $scope.selected_semester = null
  $scope.current_user = current_user
  $scope.student = student

  $scope.loaded_yes_no_milestones = false
  $scope.loaded_module_milestones = false
  $scope.loaded_milestones = false

  $scope.$on 'loaded_module_milestones', () ->
    $scope.loaded_module_milestones = true

  $scope.$watch 'loaded_module_milestones', () ->
    if $scope.loaded_module_milestones && $scope.loaded_yes_no_milestones
      $scope.loaded_milestones = true
  $scope.$watch 'loaded_yes_no_milestones', () ->
    if $scope.loaded_yes_no_milestones && $scope.loaded_module_milestones
      $scope.loaded_milestones = true

  setWidth = () ->
    windowWidth = $(window).outerWidth()
    contentWidth = $('.js-circles').outerWidth()
    sideNavWidth = $('.js-module-data-side-nav').outerWidth()
    if contentWidth >= windowWidth
      $('.js-module-data-content-container').width(contentWidth - sideNavWidth - 220)
    else
      $('.js-module-data-content-container').width(windowWidth - sideNavWidth - 220)

  $(window).resize (event) -> setWidth()

  OrganizationService.getTimeUnits(student.organization_id)
    .success (data) ->
      $scope.semesters = []
      org_time_units = data.org_time_units

      # Set up each semester in ascending order
      for tu in org_time_units
        $scope.semesters.push(tu)
        if tu.id == student.time_unit_id
          tu.name = "This Semester"
          $scope.selected_semester = $scope.semesters[$scope.semesters.length - 1]
          $scope.new_selected_semester = $scope.selected_semester

  # Loads data for all modules progress circle
  ProgressService.getAllModulesProgress($scope.student, $scope.student.time_unit_id).then (student_with_modules_progress) ->
    setWidth()
    $scope.modules_progress = student_with_modules_progress.modules_progress
    $scope.selected_module = $scope.modules_progress[0]
    $scope.student_with_modules_progress = student_with_modules_progress

  # Loads data for overall progress circle
  ProgressService.getOverallProgress($scope.student)
    .success (data) ->
      $scope.overall_points = data.overall_progress

  $scope.$watch 'selected_semester', () ->
    if $scope.selected_semester && $scope.selected_module && !$scope.loaded_yes_no_milestones
      ProgressService.yesNoMilestones($scope.student, $scope.selected_semester.id, $scope.selected_module.module_title)
        .success (data) ->
          $scope.yes_no_milestones = data.yes_no_milestones
          $scope.loaded_yes_no_milestones = true
          $scope.new_selected_semester = $scope.selected_semester

  $scope.$watch 'selected_module', () ->
    if $scope.selected_module && !$scope.loaded_yes_no_milestones
      ProgressService.yesNoMilestones($scope.student, $scope.selected_semester.id, $scope.selected_module.module_title)
        .success (data) ->
          $scope.yes_no_milestones = data.yes_no_milestones
          $scope.loaded_yes_no_milestones = true
  , true

  $scope.toggleYesNoMilestone = (milestone) ->
    if milestone.earned
      ProgressService.addUserMilestone($scope.student, $scope.selected_semester.id, milestone.id)
        .success (data) ->
          $scope.refreshPoints()
    else
      ProgressService.deleteUserMilestone($scope.student, $scope.selected_semester.id, milestone.id)
        .success (data) ->
          $scope.refreshPoints()

  $scope.refreshPoints = () ->
    # ToDo: If the overall progress circle on this page no longer needs the students picture,
    # then we don't need student_with_modules_progress and the directive can be changed to just
    # accept the modules_progress array
    # ToDo: I don't like how this works, we should revisit. Difference between checking progress
    # after saving data and then getting progress for all categories, for the full circle, and the
    # overall progress circle
    ProgressService.progressForModule($scope.student, $scope.selected_semester.id, $scope.selected_module.module_title)
      .success (data) ->
        ProgressService.getAllModulesProgress($scope.student, $scope.selected_semester.id).then (student_with_modules_progress) ->
          $scope.student_with_modules_progress = student_with_modules_progress

          selected_mod_progress = null
          for mod in $scope.modules_progress
            selected_mod_progress = mod if mod.module_title == $scope.selected_module.module_title

          # Only change the selected one so all of the cicrles don't refresh
          for mod in student_with_modules_progress.modules_progress
            selected_mod_progress.points = mod.points if mod.module_title == $scope.selected_module.module_title

        refreshOverallProgress()

  refreshOverallProgress = () ->
    ProgressService.getOverallProgress($scope.student)
      .success (data) ->
        $scope.overall_points = data.overall_progress

  $scope.selectModule = (mod) ->
    if $scope.selected_module != mod
      $scope.loaded_milestones = false
      $scope.loaded_module_milestones = false
      $scope.loaded_yes_no_milestones = false
      $scope.selected_module = mod

  $scope.selectSemester = (sem) ->
    $scope.loaded_milestones = false
    $scope.loaded_module_milestones = false
    $scope.loaded_yes_no_milestones = false

    # ToDo: If the overall progress circle on this page no longer needs the students picture,
    # then we don't need student_with_modules_progress and the directive can be changed to just
    # accept the modules_progress array
    ProgressService.getAllModulesProgress($scope.student, sem.id).then (student_with_modules_progress) ->
      $scope.modules_progress = student_with_modules_progress.modules_progress
      $scope.student_with_modules_progress = student_with_modules_progress

      for mod in $scope.modules_progress
        if mod.module_title == $scope.selected_module.module_title
          $scope.selected_module = mod

    $scope.selected_semester = sem


  $scope.getModuleTemplate = (modTitle) ->
    'progress/' + modTitle.toLowerCase() + '_progress.html' if modTitle

  $scope.editable = (user, semester) ->
    user.role != $scope.CONSTANTS.USER_ROLES.student || user.time_unit_id == semester.id

  $scope.nextSemester = () ->
    ProgressService.nextSemester($scope.student)
      .success (data) ->
        $route.reload()

  $scope.prevSemester = () ->
    ProgressService.prevSemester($scope.student)
      .success (data) ->
        $route.reload()

]
