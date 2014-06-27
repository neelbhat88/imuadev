angular.module('myApp')
.config(['$routeProvider',
  function($routeProvider) {

    $routeProvider.when('/profile', {
      templateUrl: 'profile.html',
      controller: 'ProfileController',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      }
    });

  }
]);