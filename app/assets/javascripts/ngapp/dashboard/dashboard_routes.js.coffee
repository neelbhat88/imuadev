angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/dashboard',
    templateUrl: 'dashboard/dashboard.html',
    controller: 'DashboardController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

]
