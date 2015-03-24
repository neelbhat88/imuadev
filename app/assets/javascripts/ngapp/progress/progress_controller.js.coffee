angular.module('myApp')
.controller 'ProgressController', ['$route', '$scope', 'current_user', 'student', 'OrganizationService', 'ProgressService', 'ExpectationService', 'UsersService', 'ModuleService'
($route, $scope, current_user, student, OrganizationService, ProgressService, ExpectationService, UsersService, ModuleService) ->
  $scope.modules_progress = []
  $scope.selected_module = ModuleService.selectedModule
  ModuleService.selectModule(null)
  $scope.semesters = []
  $scope.selected_semester = null
  $scope.current_user = current_user
  $scope.student = student
  $scope.needs_attention = false

  $scope.just_updated = ''
  $scope.loaded_milestones = false
  $scope.loaded_module_milestones = false
  $scope.loaded_milestones = false

  $scope.$on 'just_updated', (event, module) ->
    $scope.just_updated = module
    _.findWhere($scope.modules_progress, {module_title: module}).last_updated = new Date()

  $scope.$on 'loaded_module_milestones', () ->
    $scope.loaded_module_milestones = true

  $scope.$watch 'loaded_module_milestones', () ->
    if $scope.loaded_module_milestones && $scope.loaded_milestones
      $scope.loaded_milestones = true
  $scope.$watch 'loaded_milestones', () ->
    if $scope.loaded_module_milestones && $scope.loaded_milestones
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

  modulePointsWithLastUpdated = (student_with_modules_progress, modules_progress) ->
    user_points = 0
    total_points = 0
    for module in modules_progress
      user_points += module.points.user
      total_points += module.points.total
      switch module.module_title
        when "Academics"
          if !_.isEmpty(student_with_modules_progress.user_classes)
            sorted_module = _.sortBy(student_with_modules_progress.user_classes, (u) ->
              u.updated_at)
            module.last_updated = _.last(sorted_module).updated_at
        when "Service"
          if !_.isEmpty(student_with_modules_progress.user_service_hours)
            sorted_module = _.sortBy(student_with_modules_progress.user_service_hours, (u) ->
              u.updated_at)
            module.last_updated = _.last(sorted_module).updated_at
        when "Extracurricular"
          if !_.isEmpty(student_with_modules_progress.user_extracurricular_activity_details)
            sorted_module = _.sortBy(student_with_modules_progress.user_extracurricular_activity_details, (u) ->
              u.updated_at)
            module.last_updated = _.last(sorted_module).updated_at
        when "College_Prep" then module.last_updated = null
        when "Testing"
          if !_.isEmpty(student_with_modules_progress.user_tests)
            sorted_module = _.sortBy(student_with_modules_progress.user_tests, (u) ->
              u.updated_at)
            module.last_updated = _.last(sorted_module).updated_at

    $scope.points_earned = user_points
    $scope.total_points = total_points

  ProgressService.getUserProgressForTimeUnit($scope.student.id, $scope.student.time_unit_id)
    .success (data) ->
      $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
      $scope.student_with_modules_progress = $scope.organization.students[0]
      $scope.modules_progress = $scope.student_with_modules_progress.modules_progress
      # $scope.selected_module = $scope.modules_progress[0]
      modulePointsWithLastUpdated($scope.student_with_modules_progress, $scope.modules_progress)

      $scope.semesters = []
      for tu in $scope.organization.time_units
        $scope.semesters.push(tu)
        if tu.id == $scope.student.time_unit_id
          tu.name = "This Semester"
          $scope.selected_semester = $scope.semesters[$scope.semesters.length - 1]
          $scope.new_selected_semester = $scope.selected_semester

  ExpectationService.getUserExpectations($scope.student)
    .success (data) ->
      for ue in data.user_expectations
        if ue.status >= 2
          $scope.needs_attention = true
          break

  $scope.$watch 'selected_semester', () ->
    if $scope.selected_semester && $scope.selected_module && !$scope.loaded_milestones
      time_unit_id = $scope.selected_semester.id
      module_title = $scope.selected_module.module_title
      module_org_milestones = _.filter($scope.organization.milestones, (m) -> m.time_unit_id == time_unit_id && m.module == module_title)
      module_user_milestones = _.filter($scope.student_with_modules_progress.user_milestones, (m) -> m.time_unit_id == time_unit_id && m.module == module_title)
      $scope.milestones = UsersService.determineEarnedMilestones(module_org_milestones, module_user_milestones)
      $scope.loaded_milestones = true
      $scope.new_selected_semester = $scope.selected_semester

  $scope.$watch 'selected_module', () ->
    if $scope.selected_semester && $scope.selected_module && !$scope.loaded_milestones
      time_unit_id = $scope.selected_semester.id
      module_title = $scope.selected_module.module_title
      module_org_milestones = _.filter($scope.organization.milestones, (m) -> m.time_unit_id == time_unit_id && m.module == module_title)
      module_user_milestones = _.filter($scope.student_with_modules_progress.user_milestones, (m) -> m.time_unit_id == time_unit_id && m.module == module_title)
      $scope.milestones = UsersService.determineEarnedMilestones(module_org_milestones, module_user_milestones)
      $scope.loaded_milestones = true
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
    time_unit_id = $scope.selected_semester.id
    module_title = $scope.selected_module.module_title
    ProgressService.getRecalculatedUserProgress($scope.student.id, time_unit_id, module_title)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization, time_unit_id)
        $scope.student_with_modules_progress = $scope.organization.students[0]
        # TODO Fix so that org_milestones and user_milestones can be filtered by
        #      module_title on the back-end and still have the semester progress
        #      circle calculated accurately
        module_org_milestones = _.filter($scope.organization.milestones, (m) -> m.time_unit_id == time_unit_id && m.module == module_title)
        module_user_milestones = _.filter($scope.student_with_modules_progress.user_milestones, (m) -> m.time_unit_id == time_unit_id && m.module == module_title)
        $scope.milestones = UsersService.determineEarnedMilestones(module_org_milestones, module_user_milestones)
        # Only change the selected module so all of the cicrles don't refresh
        selected_mod_progress = null
        for mod in $scope.modules_progress
          selected_mod_progress = mod if mod.module_title == $scope.selected_module.module_title
        for mod in $scope.student_with_modules_progress.modules_progress
          selected_mod_progress.points = mod.points if mod.module_title == $scope.selected_module.module_title

  refreshOverallProgress = () ->
    ProgressService.getOverallProgress($scope.student)
      .success (data) ->
        $scope.overall_points = data.overall_progress

  $scope.selectModule = (mod) ->
    if $scope.selected_module != mod
      $scope.loaded_milestones = false
      $scope.loaded_module_milestones = false
      $scope.loaded_milestones = false
      $scope.selected_module = mod

  $scope.selectSemester = (sem) ->
    $scope.loaded_milestones = false
    $scope.loaded_module_milestones = false
    $scope.loaded_milestones = false

    ProgressService.getUserProgressForTimeUnit($scope.student.id, sem.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization, sem.id)
        $scope.student_with_modules_progress = $scope.organization.students[0]
        $scope.modules_progress = $scope.student_with_modules_progress.modules_progress
        modulePointsWithLastUpdated($scope.student_with_modules_progress, $scope.modules_progress)
        $scope.selected_semester = sem
        $scope.new_selected_semester = sem
        # Keep the selected module consistent with the previous
        for mod in $scope.modules_progress
          if $scope.selected_module &&
             mod.module_title == $scope.selected_module.module_title
            $scope.selected_module = mod

  $scope.getModuleTemplate = (modTitle) ->
    # ONEGOAL_HACK START
    if $scope.organization.name == "OneGoal"
      'progress/college_prep_progress.html'
    else
    # ONEGOAL_HACK END
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
