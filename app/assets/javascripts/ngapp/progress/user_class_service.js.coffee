angular.module("myApp")
.service "UserClassService", ['$http', ($http) ->
  
  @all = (user, time_unit_id) ->
    $http.get "/api/v1/users/#{user.id}/time_unit/#{time_unit_id}/classes"

  @new = (user) ->
    name: "",
    grade: "",
    time_unit_id: user.time_unit_id,
    user_id: user.id,
    editing: true

  @save = (user_class) ->
    if user_class.id
      return $http.put "/api/v1/users/#{user_class.user_id}/classes/#{user_class.id}", {user_class: user_class}
    else
      return $http.post "/api/v1/users/#{user_class.user_id}/classes", {user_class: user_class}

  @delete = (user_class) ->
    return $http.delete "/api/v1/users/#{user_class.user_id}/classes/#{user_class.id}"

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
