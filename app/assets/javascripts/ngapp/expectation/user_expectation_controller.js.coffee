angular.module('myApp')
.controller 'UserExpectationController', ['$scope', 'current_user', 'student', 'user_expectation', 'ExpectationService',
  ($scope, current_user, student, user_expectation, ExpectationService) ->
    $scope.current_user = current_user
    $scope.student = student
    $scope.user_expectation = user_expectation
    $scope.user_expectation_history = null

    $scope.editing = false
    $scope.new_status = null
    $scope.old_status = null
    $scope.new_comment = null

    ExpectationService.getUserExpectationHistory($scope.user_expectation.id)
      .success (data) ->
        $scope.user_expectation_history = data.user_expectation_history

    $scope.editExpectation = (status) ->
      $scope.editing = true
      $scope.old_status = $scope.user_expectation.status
      $scope.user_expectation.status = status
      $scope.new_comment = null

    $scope.cancelEditing = () ->
      $scope.editing = false
      $scope.user_expectation.status = $scope.old_status
      $scope.new_comment = null

    $scope.updateExpectation = () ->
      $scope.user_expectation.comment = $scope.new_comment

      ExpectationService.updateUserExpectation($scope.user_expectation)
        .success (data) ->
          $scope.user_expectation = data.user_expectation
          $scope.user_expectation_history.unshift(angular.copy(data.user_expectation))
          $scope.editing = false
          $scope.new_comment = null

    $scope.getHistoryColor = (status) ->
      switch status
        when $scope.CONSTANTS.EXPECTATION_STATUS.meeting then "good"
        when $scope.CONSTANTS.EXPECTATION_STATUS.needs_work then "warn"
        when $scope.CONSTANTS.EXPECTATION_STATUS.not_meeting then "alert"

    $scope.getStatusText = (status) ->
      switch status
        when $scope.CONSTANTS.EXPECTATION_STATUS.meeting then "Meeting"
        when $scope.CONSTANTS.EXPECTATION_STATUS.needs_work then "Needs Work"
        when $scope.CONSTANTS.EXPECTATION_STATUS.not_meeting then "Not Meeting"

]
