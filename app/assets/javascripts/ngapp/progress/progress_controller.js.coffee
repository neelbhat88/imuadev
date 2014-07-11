angular.module('myApp')
.controller 'ProgressController', ['$scope', 'current_user', 'student', 'OrganizationService', 'ProgressService',
($scope, current_user, student, OrganizationService, ProgressService) ->
  $scope.selected_module = null
  $scope.semesters = []
  $scope.current_user = current_user
  $scope.student = student
  $scope.selected_semester = null

  setWidth = () ->
    windowWidth = $(window).outerWidth()
    contentWidth = $('.js-module-circles').outerWidth()
    sideNavWidth = $('.js-module-data-side-nav').outerWidth()
    if contentWidth >= windowWidth
      $('.js-module-data-content-container').width(contentWidth - sideNavWidth - 20)
    else
      $('.js-module-data-content-container').width(windowWidth - sideNavWidth - 20)

  $(window).resize (event) -> setWidth()

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
      setWidth()
      $scope.modules_progress = data.modules_progress
      $scope.selected_module = data.modules_progress[0]
      $scope.student_with_modules_progress = {user: $scope.student, modules_progress: $scope.modules_progress}

  $scope.$watch 'selected_semester', () ->
    if $scope.selected_semester
      $scope.$watch 'selected_module', () ->
        if $scope.selected_module
          ProgressService.yesNoMilestones($scope.student, $scope.selected_semester.id, $scope.selected_module.module_title)
            .success (data) ->
              $scope.yes_no_milestones = data.yes_no_milestones
              $scope.loaded_yes_no_milestones = true

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
    # ToDo: Might be better to broadcast something here that progresscontroller lisents for and then updates progress accordingly
    ProgressService.progressForModule($scope.student, $scope.selected_semester.id, $scope.selected_module.module_title)
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

    $scope.selected_semester = sem

  $scope.getModuleTemplate = (modTitle) ->
    'progress/' + modTitle.toLowerCase() + '_progress.html' if modTitle

  $scope.editable = (user, semester) ->
    user.role != $scope.CONSTANTS.USER_ROLES.student || user.time_unit_id == semester.id

]
