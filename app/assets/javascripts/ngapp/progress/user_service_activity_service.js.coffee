angular.module("myApp")
.service "UserServiceActivityService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/service_activity_events?time_unit_id=#{time_unit_id}"

  @newServiceActivity = (user, time_unit_id) ->
    name: "",
    description: "",
    user_id: user.id,
    editing: true

  @newServiceEvent = (user, time_unit_id, service_activity_id) ->
    name: "",
    user_service_activity_id: service_activity_id,
    hours: "",
    date: "",
    time_unit_id: time_unit_id,
    user_id: user.id,
    description: "",
    editing: true

  @saveServiceActivity = (user_service_activity) ->
    if user_service_activity.id
      return $http.put "/api/v1/service_activity/#{user_service_activity.id}", {user_service_activity: user_service_activity}
    else
      return $http.post "/api/v1//service_activity", {user_service_activity: user_service_activity}

  @saveServiceEvent = (user_service_activity_event) ->
    if user_service_activity_event.id
      return $http.put "/api/v1/service_activity_event/#{user_service_activity_event.id}", {user_service_activity_event: user_service_activity_event}
    else
      return $http.post "/api/v1/service_activity_event", {user_service_activity_event: user_service_activity_event}

  @deleteServiceActivity = (user_service_activity) ->
    return $http.delete "/api/v1/service_activity/#{user_service_activity.id}"

  @deleteServiceEvent = (user_service_activity_event) ->
    return $http.delete "/api/v1/service_activity_event/#{user_service_activity_event.id}"

  @
]
