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

      edit: ['$route', ($route) ->
        $route.current.params.edit
      ]
]
