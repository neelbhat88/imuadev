angular.module('myApp')
.controller 'StudentExpectationController', ['$route', '$scope', 'student', 'current_user', 'ExpectationService', 'ProgressService',
  ($route, $scope, student, current_user, ExpectationService, ProgressService) ->

    $scope.current_user = current_user
    $scope.student = student
    $scope.orgId = $scope.student.organization_id
    $scope.studentId = $scope.student.id
    $scope.meetingExpectations = true

    $scope.expectations = []

    ProgressService.getAllModulesProgress($scope.student, $scope.student.time_unit_id).then (student_with_modules_progress) ->
      $scope.modules_progress = student_with_modules_progress.modules_progress
      $scope.selected_module = $scope.modules_progress[0]
      $scope.student_with_modules_progress = student_with_modules_progress

    ExpectationService.getExpectations($scope.orgId)
      .success (data) ->
        $scope.expectations = data.expectations
        ExpectationService.getUserExpectations($scope.student)
          .success (data) ->
            for e in $scope.expectations
              for ue in data.user_expectations
                if e.id == ue.expectation_id
                  e.user_expectation = ue
                  # TODO splice ue out of data.user_expectations
                  break

            $scope.recalculateMeetingExpectations()
            $scope.loaded_expectations = true

    $scope.setUserExpectationStatus = (expectation, status) ->
      if expectation.user_expectation.status != status
        expectation.user_expectation.status = status
        ExpectationService.updateUserExpectation(expectation.user_expectation)
          .success (data) ->
            expectation.user_expectation = data.user_expectation
            $scope.recalculateMeetingExpectations()

    $scope.viewExpectationHistory = (expectation) ->
      ExpectationService.getUserExpectationHistory($scope.studentId, expectation.id)
        .success (data) ->
          expectation.user_expectation.history = []
          expectation.user_expectation.history = data.expectation_history
          expectation.user_expectation.showHistory = true

    $scope.hideExpectationHistory = (expectation) ->
      expectation.user_expectation.showHistory = false

    $scope.recalculateMeetingExpectations = () ->
      for expectation in $scope.expectations
        if expectation.user_expectation.status > 0
          $scope.meetingExpectations = false
          return
      $scope.meetingExpectations = true

]
