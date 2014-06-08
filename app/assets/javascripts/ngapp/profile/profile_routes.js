angular.module('myApp')
.config(['$routeProvider',
  function($routeProvider) {

    $routeProvider.when('/profile', {
      templateUrl: '/assets/profile.tmpl.html',
      controller: 'ProfileController',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      }
    });

  }
]);