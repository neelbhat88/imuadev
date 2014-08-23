angular.module('myApp')
.controller "OrgAdminDashboardController", ["$scope",
($scope) ->

  $scope.current_organization = "Hoku Scholars"
  $scope.active_mentors = "5"
  $scope.active_students = "36"
  $scope.average_gpa = "3.14"
  $scope.average_serviceHours = "7.2"
  $scope.average_ecActivities = "1.3"
  $scope.average_testsTaken = "0.6"

]
