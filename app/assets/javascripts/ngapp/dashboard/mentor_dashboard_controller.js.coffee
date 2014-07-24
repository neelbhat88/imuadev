angular.module('myApp')
.controller "MentorDashboardController", ["$scope", "UsersService", "ProgressService",
($scope, UsersService, ProgressService) ->
  $scope.assigned_students = []
  $scope.mentor = $scope.user

  UsersService.getAssignedStudents($scope.mentor.id)
  .success (data) ->
    for student in data.students
      ProgressService.getModulesProgress(student).then (student_with_modules_progress) ->
        $scope.assigned_students.unshift(student_with_modules_progress)

]
