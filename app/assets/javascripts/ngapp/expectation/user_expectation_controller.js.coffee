angular.module('myApp')
.controller 'UserExpectationController', ['$scope', 'current_user', 'student', 'user_expectation', 'ExpectationService',
  ($scope, current_user, student, user_expectation, ExpectationService) ->
    $scope.current_user = current_user
    $scope.student = student
    $scope.user_expectation = user_expectation
    $scope.user_expectation_history = null

    $scope.editing = false
    $scope.old_status = null
    $scope.user_expectation.new_comment = null
    $scope.original_expectaton_status = null

    ExpectationService.getUserExpectationHistory($scope.user_expectation.id)
      .success (data) ->
        $scope.user_expectation_history = data.user_expectation_history

    $scope.editExpectation = () ->
      $scope.editing = true
      $scope.old_status = angular.copy($scope.user_expectation)
      if $scope.old_status.modified_by_name == null
        $scope.old_status.modified_by_name = $scope.current_user.full_name

    $scope.cancelEditing = () ->
      $scope.editing = false
      $scope.user_expectation.status = $scope.old_status.status
      $scope.user_expectation.new_comment = null

    $scope.editComment = () ->
      $scope.edit_comment = true
      $scope.user_expectation.edit_comment = $scope.user_expectation.comment

    $scope.cancelCommentEdit = () ->
      $scope.edit_comment = false

    $scope.updateComment = () ->
      $scope.user_expectation.comment = $scope.user_expectation.edit_comment

      ExpectationService.updateUserExpectationComment($scope.user_expectation)
        .success (data) ->
          $scope.user_expectation = data.user_expectation

      $scope.edit_comment = false

    $scope.updateExpectation = () ->
      $scope.user_expectation.comment = $scope.user_expectation.new_comment

      ExpectationService.updateUserExpectation($scope.user_expectation)
        .success (data) ->
          if !!$scope.old_status
            $scope.user_expectation_history.unshift($scope.old_status)
          $scope.user_expectation = data.user_expectation
          $scope.editing = false
          $scope.user_expectation.new_comment = null

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
