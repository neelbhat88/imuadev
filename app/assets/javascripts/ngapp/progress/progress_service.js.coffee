angular.module('myApp')
.service 'ProgressService', ['$http', ($http) ->

  @getModules = (user, time_unit_id) ->
    $http.get "/api/v1/users/#{user.id}/time_unit/#{time_unit_id}/progress"

  @
]
