angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/:trackable_route/:trackable_id/activity',
  # $routeProvider.when '/activity',
    templateUrl: 'activity/activity.html',
    controller: 'ActivityController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]

      activity: ['$q', '$route', 'ActivityService', ($q, $route, ActivityService) ->
        defer = $q.defer()
        # ActivityService.getActivity("user_class", 115)
        ActivityService.doGetActivity($route.current.params.trackable_route, $route.current.params.trackable_id)
          .success (data) ->
            defer.resolve(ActivityService.parseActivity(data.organization))
          .error (data) ->
            defer.reject()
        defer.promise
      ]
]
