angular.module('myApp')
.controller 'UserExpectationController', ['$scope', 'current_user', 'user_expectation',
  ($scope, current_user, user_expectation) ->
    $scope.current_user = current_user
    $scope.user_expectation = user_expectation
]
