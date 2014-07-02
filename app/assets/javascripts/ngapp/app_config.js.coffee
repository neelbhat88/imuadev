angular.module('myApp').config ['$routeProvider', '$httpProvider', 'CONSTANTS',
($routeProvider, $httpProvider, CONSTANTS) ->
  $routeProvider.when '/',
    templateUrl: 'roadmap/roadmap.html',
    controller: 'RoadmapController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser();
      ]

  .otherwise
    redirectTo: '/'
]
