angular.module("myApp")
.service "UserServiceActivityService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/time_unit/#{time_unit_id}/service_activity_events"

  @newServiceActivity = (user, time_unit_id) ->
    name: "",
    user_id: user.id,
    editing: true

  @newServiceActivityEvent = (user, time_unit_id) ->
    name: "",
    user_service_activity_id: "",
    hours: "",
    date: "",
    time_unit_id: time_unit_id,
    user_id: user.id,
    description: "",
    editing: true

  @saveServiceActivity = (user_service_activity) ->
    if user_service_activity.id
      return $http.put "/api/v1/users/#{user_service_activity.user_id}/service_activity/#{user_service_activity.id}", {user_service_activity: user_service_activity}
    else
      return $http.post "/api/v1/users/#{user_service_activity.user_id}/service_activity", {user_service_activity: user_service_activity}

  @saveServiceActivityEvent = (user_service_activity_event) ->
    if user_service_activity_event.id
      return $http.put "/api/v1/users/#{user_service_activity_event.user_id}/service_activity_event/#{user_service_activity_event.id}", {user_service_activity_event: user_service_activity_event}
    else
      return $http.post "/api/v1/users/#{user_service_activity_event.user_id}/service_activity_event", {user_service_activity_event: user_service_activity_event}

  @delete = (user_class) ->
    return $http.delete "/api/v1/users/#{user_class.user_id}/classes/#{user_class.id}"
  @
]
