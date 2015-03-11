angular.module('myApp')
.controller 'AddTaskModalController', ['$scope', '$modalInstance', 'selectedStudents',
                                        'current_user', 'AssignmentService',
  ($scope, $modalInstance, selectedStudents, current_user, AssignmentService) ->

    $scope.current_user = current_user
    $scope.selectedStudents = selectedStudents
    $scope.assignment = {}
    $scope.assignment.new_title = ''

    $scope.saveTask = () ->
      $scope.noName = false
      new_assignment = AssignmentService.newAssignment($scope.current_user.id)
      new_assignment.user_id = $scope.current_user.id
      new_assignment.title = $scope.assignment.new_title
      new_assignment.description = $scope.assignment.new_description
      new_assignment.due_datetime = $scope.assignment.new_due_datetime
      new_assignment.assignees = $scope.selectedStudents

      if $scope.assignment.new_title != ''
        AssignmentService.broadcastAssignment(new_assignment, _.map(new_assignment.assignees, (assignee) -> assignee.id))
          .success (data) ->
            $modalInstance.close()
      else
        $scope.noName = true

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

]
