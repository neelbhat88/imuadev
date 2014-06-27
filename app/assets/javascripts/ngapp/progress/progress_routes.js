angular.module('myApp')
.config(['$routeProvider',
  function($routeProvider) {

    $routeProvider.when('/progress', {
      templateUrl: 'progress/progress.html',
      controller: 'ProgressController',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      }
    });

  }
]);