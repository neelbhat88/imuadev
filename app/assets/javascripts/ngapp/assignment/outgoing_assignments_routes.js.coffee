angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/assignments/:user_id',
    templateUrl: 'assignment/outgoing_assignments.html',
    controller: 'OutgoingAssignmentsController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
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
