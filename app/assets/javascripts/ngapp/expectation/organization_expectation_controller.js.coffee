angular.module('myApp')
.controller 'OrganizationExpectationController', ['$route', '$scope', 'ExpectationService',
  ($route, $scope, ExpectationService) ->

    $scope.user = $scope.current_user
    $scope.orgId = $scope.user.organization_id
    $scope.expectations = []

    ExpectationService.getExpectations($scope.orgId)
      .success (data) ->
        $scope.expectations = data.expectations
        for e in $scope.expectations
          e.editing = false
        $scope.expectations.editing = false
        $scope.loaded_expectations = true

    $scope.editExpectation = (index) ->
      $scope.expectations[index].editing = true
      $scope.expectations[index].new_title = $scope.expectations[index].title;

    $scope.cancelEditExpectation = (index) ->
      if $scope.expectations[index].id
        $scope.expectations[index].editing = false
      else
        $scope.expectations.splice(index, 1)
      $scope.expectations.editing = false

    $scope.saveExpectation = (index) ->
      new_expectation = ExpectationService.newExpectation($scope.orgId)
      new_expectation.id = $scope.expectations[index].id
      new_expectation.title = $scope.expectations[index].new_title

      if new_expectation.id && new_expectation.title != $scope.expectations[index].title
        if !window.confirm "This will rename the expectation while maintaining each student's corresponding expectation status. Ok to continue?"
          return

      ExpectationService.saveExpectation(new_expectation)
        .success (data) ->
          $scope.expectations[index] = data.expectation
          $scope.expectations[index].editing = false
          $scope.expectations.editing = false

    $scope.deleteExpectation = (index) ->
      if window.confirm "Are you sure you want to delete this expectation? This will remove the corresponding expectation status at each student."
        ExpectationService.deleteExpectation($scope.expectations[index])
          .success (data) ->
            $scope.expectations.splice(index, 1)

    $scope.addExpectation = () ->
      $scope.expectations.editing = true
      blank_expectation = ExpectationService.newExpectation($scope.orgId)
      blank_expectation.editing = true
      $scope.expectations.push(blank_expectation)
]
