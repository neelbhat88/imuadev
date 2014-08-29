angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
    $routeProvider.when '/roadmap/:id',
      templateUrl: 'roadmap/roadmap.html',
      controller: 'RoadmapController',
      resolve:
        current_user: ['SessionService', (SessionService) ->
          SessionService.getCurrentUser()
        ]
]
