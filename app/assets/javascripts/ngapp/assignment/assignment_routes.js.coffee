angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/assignment/:assignment_id',
    templateUrl: 'assignment/assignment.html',
    controller: 'AssignmentController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      assignment: ['$q', '$route', 'AssignmentService', 'OrganizationService', ($q, $route, AssignmentService, OrganizationService) ->
        defer = $q.defer()
        if parseInt($route.current.params.assignment_id, 10) == -1
          defer.resolve(null)
        else
          AssignmentService.getAssignmentCollection($route.current.params.assignment_id)
            .success (data) ->
              organization = OrganizationService.parseOrganizationWithUsers(data.organization)
              defer.resolve(organization.assignments[0])
            .error (data) ->
              defer.reject()
        defer.promise
      ]

      edit: ['$route', ($route) ->
        $route.current.params.edit
      ]
]
