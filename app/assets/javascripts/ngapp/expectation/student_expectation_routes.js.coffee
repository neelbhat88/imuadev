angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/expectations/:user_id',
    templateUrl: 'expectation/student_expectations.html',
    controller: 'StudentExpectationController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      student: ['$q', '$route', 'UsersService', ($q, $route, UsersService) ->
        defer = $q.defer()

        UsersService.getUser($route.current.params.user_id)
          .success (data) ->
            defer.resolve(data.user)

          .error (data) ->
            defer.reject()

        defer.promise
      ]
]
