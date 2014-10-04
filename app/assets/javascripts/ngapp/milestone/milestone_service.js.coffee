angular.module('myApp')
.service 'MilestoneService', ['$http', ($http) ->
  self = this

  @getMilestoneStatus = (milestoneId) ->
    $http.get "api/v1/milestone/#{milestoneId}/status"

  @
]
