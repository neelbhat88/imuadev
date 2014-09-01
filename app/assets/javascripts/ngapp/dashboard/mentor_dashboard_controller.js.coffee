angular.module('myApp')
.controller "MentorDashboardController", ["$scope", "$modal", "UsersService", "ProgressService", "ExpectationService", "OrganizationService",
($scope, $modal, UsersService, ProgressService, ExpectationService, OrganizationService) ->

  $scope.assigned_students = []
  $scope.attention_students = []
  $scope.mentor = $scope.user

  UsersService.getAssignedStudents($scope.mentor.id)
    .success (data) ->
      $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
      $scope.assigned_students = $scope.organization.students
      $scope.attention_students = _.where($scope.organization.students, { needs_attention: true })
      $scope.loaded_users = true

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
