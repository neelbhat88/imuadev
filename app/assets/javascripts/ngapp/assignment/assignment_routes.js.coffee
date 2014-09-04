angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/assignment/:assignment_id',
    templateUrl: 'assignment/assignment.html',
    controller: 'AssignmentController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      assignment: ['$q', '$route', 'AssignmentService', ($q, $route, AssignmentService) ->
        defer = $q.defer()
        if parseInt($route.current.params.assignment_id, 10) == -1
          defer.resolve(null)
        else
          AssignmentService.collectAssignment($route.current.params.assignment_id)
            .success (data) ->
              defer.resolve(data.assignment_collection)
            .error (data) ->
              defer.reject()
        defer.promise
      ]

      edit: ['$route', ($route) ->
        $route.current.params.edit
      ]
]
