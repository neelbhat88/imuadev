angular.module('myApp')
.service 'MilestoneService', ['$http', '$q', ($http, $q) ->
  self = this

  @newMilestone = (_organization_id, _time_unit_id, _module, _submodule, _title, _description, _icon) ->
    organization_id: _organization_id,
    time_unit_id: _time_unit_id,
    module: _module,
    submodule: _submodule,
    title: _title,
    description: _description,
    icon: _icon

  @parseMilestoneStatus = (org) ->
    org.students = _.each(_.where(org.users, { role: 50 }), (s) -> s.modules_progress = [] )
    org.mentors = _.each(_.where(org.users, { role: 40 }), (m) -> m.modules_progress = [] )
    org.orgAdmins = _.where(org.users, { role: 10 })

    _.each(org.milestones, (m) -> m.time_unit_name = _.find(org.time_units, (tu) -> tu.id == m.time_unit_id).name)

    if org.assignments != undefined
      for a in org.assignments
        switch a.assignment_owner_type
          when "User"
            a.user = _.find(org.users, (u) -> a.assignment_owner_id == u.id)
            if a.user.assignments == undefined
              a.user.assignments = []
            a.user.assignments.push(a)
          when "Milestone"
            a.milestone = _.find(org.milestones, (m) -> a.assignment_owner_id == m.id)
            if a.milestone.assignments == undefined
              a.milestone.assignments = []
            a.milestone.assignments.push(a)
        a.user_assignments = []

    if org.user_assignments != undefined
      for ua in org.user_assignments
        ua.user = _.find(org.users, (u) -> ua.user_id == u.id)
        if ua.user.user_assignments == undefined
          ua.user.user_assignments = []
        ua.user.user_assignments.push(ua)
        ua.assignment = _.find(org.assignments, (a) -> ua.assignment_id == a.id)
        ua.assignment.user_assignments.push(ua)

    for um in org.user_milestones
      um.milestone = _.find(org.milestones, (m) -> um.milestone_id == m.id)
      if um.milestone.user_milestones == undefined
        um.milestone.user_milestones = []
      um.milestone.user_milestones.push(um)
      um.user = _.find(org.users, (u) -> um.user_id == u.id)
      if um.user.user_milestones == undefined
        um.user.user_milestones = []
      um.user.user_milestones.push(um)

    return org

  @_getMilestoneStatus = (milestoneId) ->
    $http.get "api/v1/milestone/#{milestoneId}/status"

  @getMilestoneStatus = (milestoneId) ->
    defer = $q.defer()
    @_getMilestoneStatus(milestoneId)
      .success (data) ->
        defer.resolve(data)
    defer.promise

  @
]
