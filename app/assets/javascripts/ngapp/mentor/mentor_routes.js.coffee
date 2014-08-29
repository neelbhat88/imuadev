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

      assigned_students: ['$q', '$route', 'UsersService', 'ProgressService', 'OrganizationService',
      ($q, $route, UsersService, ProgressService, OrganizationService) ->
        defer = $q.defer()

        UsersService.getAssignedStudents($route.current.params.id)
          .success (data) ->
            organization = OrganizationService.parseOrganizationWithUsers(data.organization)
            defer.resolve(organization.students)

        defer.promise
      ]
]
