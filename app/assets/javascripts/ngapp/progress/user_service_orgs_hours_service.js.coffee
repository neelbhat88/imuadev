angular.module("myApp")
.service "UserServiceOrgsHoursService", ['$http', ($http) ->

  @all = (userId, time_unit_id) ->
    $http.get "/api/v1/users/#{userId}/time_unit/#{time_unit_id}/service_orgs_hours"

  @
]
