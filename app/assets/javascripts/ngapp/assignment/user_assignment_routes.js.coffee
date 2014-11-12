angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/user_assignment/:user_assignment_id',
    templateUrl: 'assignment/user_assignment.html',
    controller: 'UserAssignmentController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      user_assignment: ['$q', '$route', 'AssignmentService', 'OrganizationService', ($q, $route, AssignmentService, OrganizationService) ->
        defer = $q.defer()
        AssignmentService.collectUserAssignment($route.current.params.user_assignment_id)
          .success (data) ->
            organization = OrganizationService.parseOrganizationWithUsers(data.organization)
            defer.resolve(organization.user_assignments[0])
          .error (data) ->
            defer.reject()
        defer.promise
      ]
]
