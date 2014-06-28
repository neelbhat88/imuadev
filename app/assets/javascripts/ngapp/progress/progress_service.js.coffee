angular.module('myApp')
.service 'ProgressService', ['$http', ($http) ->

  @getModules = (user, time_unit_id) ->
    $http.post '/api/v1/progress/modules',
      user_id: user.id,
      organization_id: user.organization_id,
      time_unit_id: time_unit_id

  @
]
