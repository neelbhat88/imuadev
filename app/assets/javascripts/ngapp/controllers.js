angular.module('myApp.controllers', [])

.controller('HeaderController', ['$scope', 'SessionService',
  function($scope, SessionService) {
    SessionService.getCurrentUser().then(function(user){
      $scope.user = user;
    });
  }
]);