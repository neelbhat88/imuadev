angular.module("myApp")
.service "UserClassService", ['$http', 'CONSTANTS', ($http, CONSTANTS) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/user_class?time_unit=#{time_unit_id}"

  @new = (user, time_unit_id) ->
    name: "",
    grade: null,
    gpa: 0,
    period: null,
    room: null,
    credit_hours: 1,
    level: CONSTANTS.CLASS_LEVELS.regular
    subject: ""
    time_unit_id: time_unit_id,
    user_id: user.id,
    editing: true

  @save = (user_class) ->
    if user_class.id
      return $http.put "/api/v1/user_class/#{user_class.id}", {user_class: user_class}
    else
      return $http.post "/api/v1/users/#{user_class.user_id}/user_class", {user_class: user_class}

  @delete = (user_class) ->
    return $http.delete "/api/v1/user_class/#{user_class.id}"

  @
]
