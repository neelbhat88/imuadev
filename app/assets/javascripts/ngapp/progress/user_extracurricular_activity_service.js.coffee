angular.module("myApp")
.service "UserExtracurricularActivityService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/extracurricular_activity_details?time_unit_id=#{time_unit_id}"

  @newExtracurricularActivity = (student) ->
    name: "",
    user_id: student.id,
    editing: true

  @newExtracurricularDetail = (student, time_unit_id, extracurricularActivityId) ->
      name: "",
      user_extracurricular_activity_id: extracurricularActivityId,
      time_unit_id: time_unit_id,
      user_id: student.id,
      leadership: "",
      description: ""

  @saveExtracurricularActivity = (user_extracurricular_activity) ->
      return $http.put "/api/v1/user_extracurricular_activity/#{user_extracurricular_activity.id}", {user_extracurricular_activity: user_extracurricular_activity, user_extracurricular_detail: user_extracurricular_activity.details[0]}

  @saveNewExtracurricularActivity = (new_extracurricular_activity) ->
      return $http.post "/api/v1/user_extracurricular_activity", {user_extracurricular_activity: new_extracurricular_activity, user_extracurricular_detail: new_extracurricular_activity.details[0]}

  @saveExtracurricularDetail = (user_extracurricular_detail) ->
    if user_extracurricular_detail.id
      return $http.put "/api/v1/user_extracurricular_activity_detail/#{user_extracurricular_detail.id}", {user_extracurricular_detail: user_extracurricular_detail}
    else
      return $http.post "/api/v1/user_extracurricular_activity_detail", {user_extracurricular_detail: user_extracurricular_detail}

  @deleteExtracurricularActivity = (user_extracurricular_activity, time_unit_id) ->
    return $http.delete "/api/v1/user_extracurricular_activity/#{user_extracurricular_activity.id}?time_unit_id=#{time_unit_id}"

  @
]
