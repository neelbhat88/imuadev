angular.module('myApp')
.controller 'StudentExpectationController', ['$route', '$scope', 'student', 'current_user', 'ExpectationService',
  ($route, $scope, student, current_user, ExpectationService) ->

    $scope.current_user = current_user
    $scope.student = student
    $scope.orgId = $scope.student.organization_id
    $scope.studentId = $scope.student.id

    $scope.expectations = []

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
              if not e.user_expectation?
                e.user_expectation = ExpectationService.newUserExpectation($scope.studentId, e.id, 0)
            $scope.loaded_expectations = true

    $scope.setUserExpectationStatus = (expectation, status) ->
      if expectation.user_expectation.status != status
        for e in $scope.expectations
          if e.id == expectation.id
            user_expectation = ExpectationService.newUserExpectation($scope.studentId, e.id, status)
            user_expectation.id = e.user_expectation.id
            ExpectationService.saveUserExpectation(user_expectation)
              .success (data) ->
                e.user_expectation = data.user_expectation
            break

]
