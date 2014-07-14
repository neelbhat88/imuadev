angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/profile/:user_id',
    templateUrl: 'profile.html',
    controller: 'ProfileController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser();
      ]

      user: ['$q', '$route', 'UsersService', ($q, $route, UsersService) ->
        defer = $q.defer()

        UsersService.getUser($route.current.params.user_id)
          .success (data) ->
            defer.resolve(data.user)

          .error (data) ->
            defer.reject()

        defer.promise
      ]
]
