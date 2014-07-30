angular.module('myApp')
.controller "StudentDashboardController", ["$scope", "ProgressService", "OrganizationService", "UsersService",
($scope, ProgressService, OrganizationService, UsersService) ->
  $scope.student_with_modules_progress = null
  $scope.student = $scope.user
  $scope.overall_points = {user: 0, total: 0, percent: 0}
  $scope.student_mentors = []

  setMiddleDimensions = () ->
    windowWidth = $(window).outerWidth()
    contentWidth = $('.dashboard-header--student').outerWidth()
    sideNavWidth = $('.mentor-list').outerWidth()
    if contentWidth >= windowWidth
      $('.middle-content-container').width(contentWidth - sideNavWidth - 260)
    else
      $('.middle-content-container').width(windowWidth - sideNavWidth - 260)

    height = $(window).outerHeight() - $('.dashboard-header--student').height()
    $('.middle-content-container').height(height)

  $(window).resize (event) -> setMiddleDimensions()

  ProgressService.getAllModulesProgress($scope.student, $scope.student.time_unit_id).then (student_with_modules_progress) ->
    $scope.student_with_modules_progress = student_with_modules_progress
    setMiddleDimensions()

  $scope.loaded_overall_points = false
  OrganizationService.getTimeUnits($scope.student.organization_id)
    .success (data) ->
      $scope.semesters = data.org_time_units
      for sem in $scope.semesters
        ProgressService.getModules($scope.student, sem.id)
          .success (data) ->
            for m in data.modules_progress
              $scope.overall_points.user += m.points.user
              $scope.overall_points.total += m.points.total
              $scope.overall_points.percent = Math.round(($scope.overall_points.user / $scope.overall_points.total) * 100)
            $scope.loaded_overall_points = true

  $scope.loaded_student_mentors = false
  UsersService.getAssignedMentors($scope.student.id)
    .success (data) ->
      $scope.student_mentors = data.mentors
      $scope.loaded_student_mentors = true
]