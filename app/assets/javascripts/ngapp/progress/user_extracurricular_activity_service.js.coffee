angular.module("myApp")
.service "UserExtracurricularActivityService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/extracurricular_activity_details?time_unit_id=#{time_unit_id}"

  @newExtracurricularActivity = (student) ->
    name: "",
    user_id: student.id,
    editing: true,
    details: {
      id: "",
      name: "",
      user_extracurricular_activity_id: "",
      hours: "",
      time_unit_id: "",
      user_id: student.id,
      leadership: "",
      description: ""
    }

  @saveExtracurricularActivityWithDetail = (user_extracurricular_activity_with_detail) ->
    if user_extracurricular_activity_with_detail.id
      return $http.put "/api/v1/extracurricular_activity_with_detail/#{user_extracurricular_activity_with_detail.id}", {user_extracurricular_activity_with_detail: user_extracurricular_activity_with_detail}
    else
      return $http.post "/api/v1/extracurricular_activity_with_detail", {user_extracurricular_activity_with_detail: user_extracurricular_activity_with_detail}

  @savePreviousActivityDetail = (user_extracurricular_activity_detail) ->
    return $http.post "/api/v1/extracurricular_activity_detail", {user_extracurricular_activity_detail: user_extracurricular_activity_detail}

  @deleteExtracurricularActivity = (user_extracurricular_activity) ->
    return $http.delete "/api/v1/extracurricular_activity/#{user_extracurricular_activity.id}"

  @
]
