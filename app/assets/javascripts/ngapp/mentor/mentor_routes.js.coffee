angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/mentor/:id',
    templateUrl: 'mentor/mentor.html',
    controller: 'MentorController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser();
      ]

      user: ['$q', '$route', 'UsersService', ($q, $route, UsersService) ->
        defer = $q.defer()

        UsersService.getUser($route.current.params.id)
          .success (data) ->
            defer.resolve(data.user)

          .error (data) ->
            defer.reject()

        defer.promise
      ]
]
