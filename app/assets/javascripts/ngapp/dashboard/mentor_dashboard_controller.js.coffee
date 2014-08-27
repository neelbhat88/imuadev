angular.module('myApp')
.controller "MentorDashboardController", ["$scope", "$modal", "UsersService", "ProgressService", "ExpectationService",
($scope, $modal, UsersService, ProgressService, ExpectationService) ->
  $scope.assigned_students = []
  $scope.attention_students = []
  $scope.mentor = $scope.user

  UsersService.getAssignedStudents($scope.mentor.id)
  .success (data) ->
    for student in data.students
      ProgressService.getAllModulesProgress(student, student.time_unit_id).then (student_with_modules_progress) ->
        $scope.assigned_students.unshift(student_with_modules_progress)
      ExpectationService.getUserExpectations(student)
        .success (data) ->
          for ue in data.user_expectations
            if ue.status >= 2
              $scope.attention_students.push(ue.user_id)
              break

  $scope.addAssignment = () ->
    modalInstance = $modal.open
      templateUrl: 'assignment/add_assignment_modal.html',
      controller: 'AddAssignmentModalController',
      backdrop: 'static',
      size: 'sm'
      resolve:
        user: () -> $scope.user
        assignees: () -> $scope.assigned_students

]
