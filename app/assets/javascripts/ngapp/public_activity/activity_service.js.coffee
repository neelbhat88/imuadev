angular.module('myApp')
.service 'ActivityService', ['$http', '$q', ($http, $q) ->

  @parseActivity = (org) ->
    org.activity = _.flatten(_.pluck(org.users, "public_activity/activities"), true)
    _.each(org.activity, (a) -> a.owner = _.findWhere(org.users, {id: a.owner_id}))
    return org.activity

  @doGetActivity = (trackable_route, trackable_id) ->
    $http.get "api/v1/#{trackable_route}/#{trackable_id}/activity"

  @getActivity = (trackable_route, trackable_id) ->
    defer = $q.defer()
    @doGetActivity(trackable_route, trackable_id)
      .success (data) ->
        defer.resolve(data.organization)
    defer.promise

  @
]
