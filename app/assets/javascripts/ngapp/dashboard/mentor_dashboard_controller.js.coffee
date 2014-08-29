angular.module('myApp')
.controller "MentorDashboardController", ["$scope", "UsersService", "ProgressService", "ExpectationService", "OrganizationService",
($scope, UsersService, ProgressService, ExpectationService, OrganizationService) ->
  $scope.mentor = $scope.user

  UsersService.getAssignedStudents($scope.mentor.id)
    .success (data) ->
      $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
      $scope.assigned_students = $scope.organization.students
      $scope.attention_students = _.where($scope.organization.students, { needs_attention: true })

      $scope.loaded_users = true

]
