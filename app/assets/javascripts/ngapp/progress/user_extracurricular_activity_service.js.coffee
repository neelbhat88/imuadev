angular.module("myApp")
.service "UserExtracurricularActivityService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/extracurricular_activity_details?time_unit_id=#{time_unit_id}"

  @newExtracurricularActivity = (user, time_unit_id, extracurricularActivityId) ->
    name: "",
    user_id: user.id,
    editing: true,
    details: [{
      name: "",
      user_extracurricular_activity_id: "",
      hours: "",
      time_unit_id: time_unit_id,
      user_id: user.id,
      leadership: "",
      description: ""
    }]

  @newExtracurricularDetail = (user, time_unit_id, extracurricularActivityId) ->
    name: "",
    user_extracurricular_activity_id: extracurricularActivityId,
    time_unit_id: time_unit_id,
    user_id: user.id,
    leadership: "",
    description: "",
    editing: true

  @saveExtracurricularActivity = (user_extracurricular_activity) ->
    if user_extracurricular_activity.id
      return $http.put "/api/v1/extracurricular_activity/#{user_extracurricular_activity.id}", {user_extracurricular_activity: user_extracurricular_activity}
    else
      return $http.post "/api/v1//extracurricular_activity", {user_extracurricular_activity: user_extracurricular_activity}

  @saveExtracurricularDetail = (user_extracurricular_activity_detail) ->
    if user_extracurricular_activity_detail.id
      return $http.put "/api/v1/extracurricular_activity_detail/#{user_extracurricular_activity_detail.id}", {user_extracurricular_activity_detail: user_extracurricular_activity_detail}
    else
      return $http.post "/api/v1/extracurricular_activity_detail", {user_extracurricular_activity_detail: user_extracurricular_activity_detail}

  @deleteExtracurricularActivity = (user_extracurricular_activity) ->
    return $http.delete "/api/v1/extracurricular_activity/#{user_extracurricular_activity.id}"

  @deleteExtracurricularDetail = (user_extracurricular_activity_detail) ->
    return $http.delete "/api/v1/extracurricular_activity_detail/#{user_extracurricular_activity_detail.id}"

  @
]
