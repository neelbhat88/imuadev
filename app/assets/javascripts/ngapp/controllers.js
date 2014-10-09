angular.module('myApp.controllers', [])

.controller('HeaderController', ['$scope', 'SessionService',
  function($scope, SessionService) {
    SessionService.getCurrentUser().then(function(user){
      $scope.current_user = user;
      console.log($scope.current_user)
    });
  }
]);
