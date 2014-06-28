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

  $httpProvider.interceptors.push ['$rootScope', ($rootScope) -> 
    requestCount = 0
    processIsLoading = (adjustment) ->
      requestCount += adjustment
      isStillLoading = requestCount > 0
      $rootScope.loading = isStillLoading
      isStillLoading
 
    request = (config) ->
      processIsLoading 1
      config
 
    response = (promise) ->
      processIsLoading -1
      promise
 
    responseError = (response) ->
      processIsLoading -1

    request: request
    response: response
    responseError: responseError
  ]
]