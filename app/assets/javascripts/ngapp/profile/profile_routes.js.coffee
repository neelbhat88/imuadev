angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/profile/:user_id',
    templateUrl: 'profile/profile.html',
    controller: 'ProfileController',
    resolve:
      user_with_contacts: ['$q', '$route', 'UsersService', ($q, $route, UsersService) ->
        defer = $q.defer()

        UsersService.getUserWithContacts($route.current.params.user_id)
          .success (data) ->
            defer.resolve(data.user_with_contacts)

          .error (data) ->
            defer.reject()

        defer.promise
      ]
]
