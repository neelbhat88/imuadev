angular.module('myApp')
.service 'GraphService', ['$http', '$q', ($http, q) ->

  @gpa = (user_ids, time_unit_ids) ->
    $http(
      method: 'GET',
      url: 'api/v1/graph/gpa',
      params: {
        "user_ids[]": user_ids,
        "time_unit_ids[]": time_unit_ids
      }
    )

  @
]
