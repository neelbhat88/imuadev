angular.module("myApp")
.service "UserExtracurricularActivityService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/extracurricular_activity_events?time_unit_id=#{time_unit_id}"

  @newExtracurricularActivity = (user, time_unit_id) ->
    name: "",
    user_id: user.id,
    editing: true

  @newExtracurricularEvent = (user, time_unit_id, extracurricularActivityId) ->
    name: "",
    user_extracurricular_activity_id: extracurricularActivityId,
    hours: "",
    date: "",
    time_unit_id: time_unit_id,
    user_id: user.id,
    description: "",
    editing: true

  @saveExtracurricularActivity = (user_extracurricular_activity) ->
    if user_extracurricular_activity.id
      return $http.put "/api/v1/extracurricular_activity/#{user_extracurricular_activity.id}", {user_extracurricular_activity: user_extracurricular_activity}
    else
      return $http.post "/api/v1//extracurricular_activity", {user_extracurricular_activity: user_extracurricular_activity}

  @saveExtracurricularEvent = (user_extracurricular_activity_event) ->
    if user_extracurricular_activity_event.id
      return $http.put "/api/v1/extracurricular_activity_event/#{user_extracurricular_activity_event.id}", {user_extracurricular_activity_event: user_extracurricular_activity_event}
    else
      return $http.post "/api/v1/extracurricular_activity_event", {user_extracurricular_activity_event: user_extracurricular_activity_event}

  @deleteExtracurricularActivity = (user_extracurricular_activity) ->
    return $http.delete "/api/v1/extracurricular_activity/#{user_extracurricular_activity.id}"

  @deleteExtracurricularEvent = (user_extracurricular_activity_event) ->
    return $http.delete "/api/v1/extracurricular_activity_event/#{user_extracurricular_activity_event.id}"

  @
]
