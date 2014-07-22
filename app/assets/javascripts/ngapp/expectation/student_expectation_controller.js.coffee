angular.module('myApp')
.controller 'StudentExpectationController', ['$route', '$scope', 'ExpectationService',
  ($route, $scope, ExpectationService) ->

    $scope.orgId = $scope.student.organization_id
    $scope.studentId = $scope.student.id

    $scope.expectations = []
    $scope.user_expectations = []

    ExpectationService.getExpectations($scope.orgId)
      .success (data) ->
        $scope.expectations = data.expectations

    ExpectationService.getUserExpectations($scope.student)
      .success (data) ->
        $scope.user_expectations = data.user_expectations


]
