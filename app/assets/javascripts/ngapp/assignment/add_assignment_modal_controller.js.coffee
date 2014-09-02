angular.module('myApp')
.controller 'AddAssignmentModalController', ['$scope', '$modalInstance', 'user', 'assignees', 'AssignmentService', 'UsersService'
  ($scope, $modalInstance, user, assignees, AssignmentService, UsersService) ->
    $scope.user = user
    $scope.assignees = assignees
    $scope.assignment = AssignmentService.newAssignment($scope.user.id)

    $scope.send = () ->
      AssignmentService.broadcastAssignment($scope.assignment, _.map($scope.assignees, (assignee) -> assignee.id))
       .success (data) ->
          $modalInstance.close(data.assignment_collection)

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

]
