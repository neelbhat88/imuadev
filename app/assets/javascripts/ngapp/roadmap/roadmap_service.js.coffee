angular.module('myApp')
.service 'RoadmapService', ['$http', '$q', ($http, $q) ->
  @newRoadmap = (orgId, name) ->
    name: name,
    organization_id: orgId  

  @getRoadmap = (orgId) ->
    defer = $q.defer()

    $http.get('/api/v1/organization/' + orgId + '/roadmap')
      .then (resp, status) ->
        if resp.data.success
          defer.resolve(resp.data)
        else
          defer.reject(resp.data)

    defer.promise

  @createRoadmap = (orgId, name) ->
    roadmap = @newRoadmap(orgId, name)

    defer = $q.defer()

    $http.post('/api/v1/roadmap', {roadmap: roadmap})
      .then (resp, status) ->
        if resp.data.success
          defer.resolve(resp.data)
        else
          defer.reject(resp.data)

    defer.promise

  @updateRoadmapName = (roadmap, newname) ->
    roadmap.name = newname

    $http.put '/api/v1/roadmap/' + roadmap.id, {roadmap: roadmap}

  @getEnabledModules = (orgId) ->
    defer = $q.defer()

    $http.get('api/v1/organization/' + orgId + '/modules')
      .then (resp, status) ->
        if resp.data.success
          defer.resolve(resp.data)
        else
          defer.reject(resp.data)

    defer.promise;

  @addTimeUnit = (orgId, rId, tu_obj) ->
    defer = $q.defer()

    time_unit =
      organization_id: orgId,
      roadmap_id: rId,
      name: tu_obj.name

    $http.post('/api/v1/time_unit', { time_unit: time_unit } )
      .then (resp, status) ->
        if resp.data.success
          defer.resolve(resp.data)
        else
          defer.reject(resp.data)

    defer.promise

  @updateTimeUnit = (time_unit) ->
    defer = $q.defer()

    $http.put('/api/v1/time_unit/' + time_unit.id, { time_unit: time_unit } )
      .then (resp, status) ->
        if resp.data.success
          defer.resolve(resp.data)
        else
          defer.reject(resp.data)

    defer.promise

  @deleteTimeUnit = (time_unit_id) ->
    defer = $q.defer()

    $http.delete('/api/v1/time_unit/' + time_unit_id)
      .then (resp, status) ->
        if resp.data.success
          defer.resolve(resp.data)
        else
          defer.reject(resp.data)

    defer.promise

  @addMilestone = (milestone) ->
    $http.post '/api/v1/milestone', {milestone: milestone}

  @updateMilestone = (milestone) ->
    $http.put '/api/v1/milestone/' + milestone.id, { milestone: milestone }

  @deleteMilestone = (milestoneId) ->
    $http.delete '/api/v1/milestone/' + milestoneId

  @validateMilestone = (timeUnit, milestone) ->
    errors = []

    for m in timeUnit.milestones
      if m.id != milestone.id && # Skip if editing the milestone
         m.module == milestone.module &&
         m.submodule == milestone.submodule &&
         m.value == milestone.value

        errors.push("A milestone of the same type and value already exists in " + timeUnit.name);
        break;

    errors

  @
]
