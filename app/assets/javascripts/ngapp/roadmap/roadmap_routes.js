angular.module('myApp')
.config(['$routeProvider',
  function($routeProvider) {

    $routeProvider.when('/roadmap', {
      templateUrl: 'roadmap/roadmap.html',
      controller: 'RoadmapController',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      }
    }).when('/roadmap-old', {
      templateUrl: 'roadmap/roadmap_old.html',
      controller: 'RoadmapController',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      }
    });

  }
]);
