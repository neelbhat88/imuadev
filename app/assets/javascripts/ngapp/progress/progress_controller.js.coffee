angular.module('myApp')
.controller 'ProgressController', ['$q', '$scope', 'current_user', 'student', 'OrganizationService', 'ProgressService',
($q, $scope, current_user, student, OrganizationService, ProgressService) ->
  $scope.modules_progress = []
  $scope.selected_module = null
  $scope.semesters = []
  $scope.selected_semester = null
  $scope.current_user = current_user
  $scope.student = student
  $scope.overall_points = {user: 0, total: 0, percent: 0}

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
          $scope.selected_semester = $scope.semesters[0]

  $scope.loaded_overall_points = false
  $scope.$watch 'selected_semester', () ->
    if !$scope.loaded_overall_points && $scope.selected_semester
      for sem in $scope.semesters
        ProgressService.getModules($scope.student, sem.id)
          .success (data) ->
            time_unit_id = data.modules_progress[0].time_unit_id
            $scope.modules_progress[time_unit_id] = data.modules_progress;
            for m in data.modules_progress
              $scope.overall_points.user += m.points.user
              $scope.overall_points.total += m.points.total
              $scope.overall_points.percent = Math.round(($scope.overall_points.user / $scope.overall_points.total) * 100)
      $scope.loaded_overall_points = true

  $scope.$watch 'modules_progress[selected_semester.id]', () ->
    if $scope.modules_progress && $scope.selected_semester && $scope.modules_progress[$scope.selected_semester.id]
      setWidth()
      if !$scope.selected_module
        $scope.selected_module = $scope.modules_progress[$scope.selected_semester.id][0]
      $scope.student_with_modules_progress = {user: $scope.student, modules_progress: $scope.modules_progress[$scope.selected_semester.id]}

  $scope.$watch 'selected_module', () ->
    if $scope.selected_module && !$scope.loaded_yes_no_milestones
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
        for mod in $scope.modules_progress[$scope.selected_semester.id] # Loop through modules on progress controller
          if mod.module_title == data.module_progress.module_title
            $scope.overall_points.user += (data.module_progress.points.user - mod.points.user)
            $scope.overall_points.total += (data.module_progress.points.total - mod.points.total)
            $scope.overall_points.percent = Math.round(($scope.overall_points.user / $scope.overall_points.total) * 100)
            mod.points = data.module_progress.points

  $scope.selectModule = (mod) ->
    if $scope.selected_module != mod
      $scope.loaded_milestones = false
      $scope.loaded_module_milestones = false
      $scope.loaded_yes_no_milestones = false
      $scope.selected_module = mod

  $scope.selectSemester = (sem) ->
    if $scope.selected_semester != sem
      $scope.loaded_milestones = false
      $scope.loaded_module_milestones = false
      $scope.loaded_yes_no_milestones = false
      ProgressService.getModules(student, sem.id)
        .success (data) ->
          $scope.found_prev_module_title = false
          for m in $scope.modules_progress[sem.id]
            if m.module_title == $scope.selected_module.module_title
              $scope.found_prev_module_title = true
              $scope.selected_module = m
              break
          if !$scope.found_prev_module_title
            $scope.selected_module = $scope.modules_progress[sem.id][0]
          $scope.modules_progress[sem.id] = data.modules_progress
          $scope.student_with_modules_progress = {user: $scope.student, modules_progress: $scope.modules_progress[sem.id]}
      $scope.selected_semester = sem


  $scope.getModuleTemplate = (modTitle) ->
    'progress/' + modTitle.toLowerCase() + '_progress.html' if modTitle

  $scope.editable = (user, semester) ->
    user.role != $scope.CONSTANTS.USER_ROLES.student || user.time_unit_id == semester.id

]
