angular.module('myApp')
.controller 'AddTaskModalController', ['$scope', '$modalInstance', 'selected_users',
                                        'owner_type', 'owner_id', 'AssignmentService',
  ($scope, $modalInstance, selected_users, owner_type, owner_id, AssignmentService) ->

    $scope.assignment = AssignmentService.newAssignment(owner_type, owner_id)
    $scope.selected_users = selected_users

    $scope.saveTask = () ->
      AssignmentService.broadcastAssignment($scope.assignment, _.map($scope.selected_users, (assignee) -> assignee.id))
        .success (data) ->
          $modalInstance.close()

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

]
