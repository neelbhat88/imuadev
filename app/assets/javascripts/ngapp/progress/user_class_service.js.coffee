angular.module("myApp")
.service "UserClassService", ['$http', 'CONSTANTS', ($http, CONSTANTS) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/user_class?time_unit=#{time_unit_id}"

  @new = (user, time_unit_id) ->
    name: "",
    grade: "",
    gpa: 0,
    period: "",
    room: "",
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

  @getGPA = (user_classes) ->
    totalGPA = 0
    totalClasses = 0

    return 0 if user_classes.length == 0

    for c in user_classes
      if c.id
        totalGPA += c.gpa
        totalClasses++

    return 0 if totalClasses == 0

    return (totalGPA / totalClasses).toFixed(2)

  @
]
