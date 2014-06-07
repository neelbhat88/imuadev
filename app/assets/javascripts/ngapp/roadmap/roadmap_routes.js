angular.module('myApp')
.config(['$routeProvider',
  function($routeProvider) {

    $routeProvider.when('/roadmap', {
      templateUrl: '/assets/roadmap/roadmap.tmpl.html',
      controller: 'RoadmapController',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      }
    });

  }
]);