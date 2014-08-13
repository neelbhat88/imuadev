angular.module('myApp')
.service 'ProgressService', ['$http', '$q', ($http, $q) ->

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

  @nextSemester = (user) ->
    $http.put "/api/v1/users/#{user.id}/time_unit/next"

  @prevSemester = (user) ->
    $http.put "/api/v1/users/#{user.id}/time_unit/previous"

  @getAllModulesProgress = (student, semester_id) ->
    defer = $q.defer()
    @getModules(student, semester_id)
      .success (data) ->
        student.modules_progress = data.modules_progress
        defer.resolve(student)
    defer.promise

  @getOverallProgress = (student) ->
    $http.get "/api/v1/users/#{student.id}/progress"

  @getRecalculatedModuleMilestones = (user, time_unit_id, module_title) ->
    $http.get "/api/v1/progress/recalculated_module_milestones/?user_id=#{user.id}&time_unit_id=#{time_unit_id}&module_title=#{module_title}"

  @
]
