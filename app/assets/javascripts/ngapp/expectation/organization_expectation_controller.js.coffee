angular.module('myApp')
.controller 'OrganizationExpectationController', ['$route', '$scope', 'ExpectationService',
  ($route, $scope, ExpectationService) ->

    $scope.user = $scope.current_user
    $scope.orgId = $scope.user.organization_id
    $scope.expectations = []

    ExpectationService.getExpectations($scope.orgId)
      .success (data) ->
        $scope.expectations = data.expectations

    $scope.saveExpectation = (index) ->
      new_expectation = ExpectationService.newExpectation($scope.orgId)
      new_expectation.id = $scope.expectations[index].id
      new_expectation.title = $scope.expectations[index].title

      ExpectationService.saveExpectation(new_expectation)
        .success (data) ->
          $scope.expectations[index] = data.expectation

    $scope.deleteExpectation = (index) ->
      if window.confirm "Are you sure you want to delete this expectation?"
        ExpectationService.deleteExpectation($scope.expectations[index])
          .success (data) ->
            $scope.expectations.splice(index, 1)

    $scope.addExpectation = () ->
      $scope.expectations.push(ExpectationService.newExpectation($scope.orgId))
]
