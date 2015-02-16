angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/student_view/:user_id',
    templateUrl: 'student_view/student_view.html',
    controller: 'StudentViewController',
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
