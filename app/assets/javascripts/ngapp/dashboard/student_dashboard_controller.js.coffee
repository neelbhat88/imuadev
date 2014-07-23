angular.module('myApp')
.controller "StudentDashboardController", ["$scope", "ProgressService", "OrganizationService",
($scope, ProgressService, OrganizationService) ->
  $scope.student_with_modules_progress = null
  $scope.student = $scope.current_user
  $scope.overall_points = {user: 0, total: 0, percent: 0}

  ProgressService.getModulesProgress($scope.student).then (student_with_modules_progress) ->
    $scope.student_with_modules_progress = student_with_modules_progress

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
]
