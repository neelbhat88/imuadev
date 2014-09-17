angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
  .when '/user_expectation/:user_expectation_id',
    templateUrl: 'expectation/user_expectation.html',
    controller: 'UserExpectationController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      user_expectation: ['$q', '$route', 'ExpectationService', ($q, $route, ExpectationService) ->
        defer = $q.defer()

        ExpectationService.getUserExpectation($route.current.params.user_expectation_id)
          .success (data) ->
            defer.resolve(data.user_expectation)

          .error (data) ->
            defer.reject()

        defer.promise
      ]
]
