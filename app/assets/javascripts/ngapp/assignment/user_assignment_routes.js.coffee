angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/user_assignment/:user_assignment_id',
    templateUrl: 'assignment/user_assignment.html',
    controller: 'UserAssignmentController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      user_assignment: ['$q', '$route', 'AssignmentService', ($q, $route, AssignmentService) ->
        defer = $q.defer()
        AssignmentService.collectUserAssignment($route.current.params.user_assignment_id)
          .success (data) ->
            defer.resolve(data.user_assignment)
          .error (data) ->
            defer.reject()
        defer.promise
      ]
]
