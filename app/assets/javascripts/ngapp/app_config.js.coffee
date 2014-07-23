angular.module('myApp').config ['$routeProvider', '$httpProvider', 'CONSTANTS',
($routeProvider, $httpProvider, CONSTANTS) ->
  $routeProvider.when '/',
    templateUrl: 'dashboard/dashboard.html',
    controller: 'DashboardController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser();
      ]

  .otherwise
    redirectTo: '/'
]
