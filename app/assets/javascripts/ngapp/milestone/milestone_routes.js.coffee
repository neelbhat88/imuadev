angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/milestone/:milestone_id',
    templateUrl: 'milestone/milestone.html',
    controller: 'MilestoneController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      milestone_id: ['$route', ($route) ->
        parseInt($route.current.params.milestone_id, 10)
      ]

      # milestone: ['$q', '$route', 'MilestoneService', 'OrganizationService', ($q, $route, MilestoneService, OrganizationService) ->
      #   defer = $q.defer()
      #   MilestoneService.getMilestoneStatus($route.current.params.milestone_id)
      #     .succeess (data) ->
      #       organization = OrganizationService.parseOrganizationWithUsers(data.organization)
      #       defer.resolve(organization.milestones[0])
      #     .error (data) ->
      #       defer.reject()
      #   defer.promise
      # ]

      edit: ['$route', ($route) ->
        $route.current.params.edit
      ]
]
