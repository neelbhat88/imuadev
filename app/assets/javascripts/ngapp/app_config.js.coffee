angular.module('myApp')
.config ['$routeProvider', '$httpProvider',
($routeProvider, $httpProvider) ->
  $routeProvider.when '/',
    templateUrl: 'dashboard/dashboard.html',
    controller: 'DashboardController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser();
      ]

      user: () -> null

  .otherwise
    redirectTo: '/'

  ######### INTERCEPTORS #########
  # Install all interceptors here
  ################################
  $httpProvider.interceptors.push('AppVersionInterceptor')
]
