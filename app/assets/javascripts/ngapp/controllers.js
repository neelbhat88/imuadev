angular.module('myApp.controllers', [])

.controller('HeaderController', ['$scope', 'Auth',
  function($scope, Auth) {
    $scope.$on('devise:logout', function (event, oldCurrentUser) {
      $('#wrapper').removeClass('toggled');
    });

    $scope.logout = function() {
      Auth.logout();
    }
  }
]);
