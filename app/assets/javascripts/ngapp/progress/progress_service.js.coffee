angular.module('myApp')
.service 'ProgressService', ['$http', ($http) ->

  @getModules = (user, time_unit_id) ->
    $http.get "/api/v1/users/#{user.id}/time_unit/#{time_unit_id}/progress"

  @progressForModule = (user, time_unit_id, module_title) ->
    $http.get "/api/v1/users/#{user.id}/time_unit/#{time_unit_id}/progress/#{module_title}"

  @yesNoMilestones = (user, time_unit_id, module_title) ->
    $http.get "/api/v1/users/#{user.id}/time_unit/#{time_unit_id}/milestones/#{module_title}/yesno"

  @addUserMilestone = (user, time_unit_id, milestone_id) ->
    $http.post "/api/v1/users/#{user.id}/time_unit/#{time_unit_id}/milestones/#{milestone_id}"

  @deleteUserMilestone = (user, time_unit_id, milestone_id) ->
    $http.delete "/api/v1/users/#{user.id}/time_unit/#{time_unit_id}/milestones/#{milestone_id}"

  @
]
