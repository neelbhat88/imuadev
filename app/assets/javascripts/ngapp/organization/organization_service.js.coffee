angular.module('myApp')
.service 'OrganizationService', ['$http', '$q', 'TaggingService', ($http, $q, TaggingService) ->

  @all = ()->
    $http.get('/api/v1/organization')

  @getOrganizationWithRoadmap = (orgId) ->
    $http.get('api/v1/organization/' + orgId + '/info_with_roadmap')

  @getOrganizationWithUsers = (orgId) ->
    $http.get('/api/v1/organization/' + orgId + '/info_with_users')

  @getTimeUnits = (orgId) ->
    $http.get('/api/v1/organization/' + orgId + '/time_units')

  @addOrganization = (name) ->
    $http.post('/api/v1/organization', {name: name})


  # Performs all the front end calculations by parsing through the raw
  # OrganizationWithUsers object. Parses student progress based on the given
  # timeUnitId. If no timeUnitId is given, then it parses student progress
  # based on the student's current time_unit_id.
  # TODO This needs to be broken down further. Much Further.
  @parseOrganizationWithUsers = (org, timeUnitId) ->

    active_user_threshold = (new Date()).getTime() - (1000*60*60*24*7) # One week ago
    org.students = _.each(_.where(org.users, { role: 50 }), (s) -> s.modules_progress = [] )
    org.mentors = _.each(_.where(org.users, { role: 40 }), (m) -> m.modules_progress = [] )
    org.orgAdmins = _.where(org.users, { role: 10 })
    org.students = TaggingService.parseTagsForUsers(org.students, org.tags, org.taggings)
    org.active_students = _.filter(org.students, (student) -> (new Date(student.last_login)).getTime() >= active_user_threshold).length
    org.active_mentors = _.filter(org.mentors, (mentor) -> (new Date(mentor.last_login)).getTime() >= active_user_threshold).length
    org.attention_studentIds = []

    _.each(org.milestones, (m) -> m.time_unit_name = _.find(org.time_units, (tu) -> tu.id == m.time_unit_id).name)
    org.org_milestones = {}
    # Sort org_milestones by time_unit_id and module_title, while tallying up total points
    for time_unit_id in _.pluck(org.time_units, "id")
      org.org_milestones[time_unit_id.toString()] = {}
      org_milestones_by_time_unit = _.filter(org.milestones, (m) -> m.time_unit_id == time_unit_id)
      for module_title in _.pluck(org.enabled_modules, "title")
        org_milestones_by_module = _.filter(org_milestones_by_time_unit, (m) -> m.module == module_title)
        org.org_milestones[time_unit_id.toString()][module_title] = org_milestones_by_module
        org.org_milestones[time_unit_id.toString()][module_title].totalPoints = 0
        for org_milestone in org_milestones_by_module
          org.org_milestones[time_unit_id.toString()][module_title].totalPoints += org_milestone.points

    # Collect all assignments
    org.assignments = _.union(_.flatten(_.pluck(org.users, "assignments")))
    org.assignments = _.without(org.assignments, undefined)
    # Associate to their owner object
    for a in org.assignments
      switch a.assignment_owner_type
        when "User"
          a.user = _.find(org.users, (u) -> a.assignment_owner_id == u.id)
        when "Milestone"
          a.milestone = _.find(org.milestones, (m) -> a.assignment_owner_id == m.id)
      a.user_assignments = []

    # Collect all user_assignments
    org.user_assignments = _.union(_.flatten(_.pluck(org.users, "user_assignments"), true))
    org.user_assignments = _.without(org.user_assignments, undefined)
    # Match all user_assignment comments to their users
    _.each(org.user_assignments, (a) -> _.each(a.comments, (c) -> c.user = _.find(org.users, (u) -> c.user_id == u.id)))

    org.total_gpa = org.semester_gpa = 0
    org.gpa_student_count = 0
    org.total_serviceHours = org.semester_serviceHours = 0
    org.total_ecActivities = org.semester_ecActivities = 0
    org.total_testsTaken = org.semester_testsTaken = 0

    org.average_gpa = 0
    org.average_serviceHours = 0
    org.average_ecActivities = 0
    org.average_testsTaken = 0

    for orgAdmin in org.orgAdmins
      # Match orgAdmins' user_assignments to their assignment
      if orgAdmin.user_assignments != undefined
        for user_assignment in orgAdmin.user_assignments
          assignment = _.find(org.assignments, (a) -> user_assignment.assignment_id == a.id)
          user_assignment.title = assignment.title
          user_assignment.due_datetime = assignment.due_datetime
          user_assignment.description = assignment.description
          user_assignment.assigner = assignment.user
          user_assignment.user = orgAdmin
          assignment.user_assignments.push(user_assignment)

    for mentor in org.mentors
      # Match mentors' user_assignments to their assignment
      if mentor.user_assignments != undefined
        for user_assignment in mentor.user_assignments
          assignment = _.find(org.assignments, (a) -> user_assignment.assignment_id == a.id)
          user_assignment.title = assignment.title
          user_assignment.due_datetime = assignment.due_datetime
          user_assignment.description = assignment.description
          user_assignment.assigner = assignment.user
          user_assignment.user = mentor
          assignment.user_assignments.push(user_assignment)

    for student in org.students
      time_unit_id = if timeUnitId? then timeUnitId else student.time_unit_id

      # Find the student's mentors
      student.mentors = []
      for mentor_id in _.uniq(_.pluck(student.relationships, "assigned_to_id"))
        mentor = _.findWhere(org.mentors, { id: mentor_id })
        if mentor
          student.mentors.push(mentor)
          if !mentor.studentIds
            mentor.studentIds = []
          mentor.studentIds.push(student.id)

      # Calculate progress for each module
      for module_title, org_milestones_by_module of org.org_milestones[time_unit_id]
        new_module_progress = { module_title: module_title, time_unit_id: time_unit_id,\
                                points: { user: 0, total: org_milestones_by_module.totalPoints } }
        for user_milestone in _.where(student.user_milestones, { time_unit_id: time_unit_id, module: module_title } )
          org_milestone = _.findWhere(org_milestones_by_module, { id: user_milestone.milestone_id } )
          if org_milestone
            new_module_progress.points.user += org_milestone.points
          else
            console.log("Error: user_milestone has no matching org_milestone.", user_milestone, org_milestones_by_module, org.org_milestones)
        student.modules_progress.push(new_module_progress)
        # Apply module_progress to the student's mentors
        for mentor in student.mentors
          mentor_module_progress = _.findWhere(mentor.modules_progress, { module_title: new_module_progress.module_title } )
          if mentor_module_progress != undefined
            mentor_module_progress.points.user += new_module_progress.points.user
            mentor_module_progress.points.total += new_module_progress.points.total
          else
            new_mentor_module_progress = { module_title: module_title, time_unit_id: null,\
                                           points: { user: new_module_progress.points.user,\
                                                     total: new_module_progress.points.total } }
            mentor.modules_progress.push(new_mentor_module_progress)

      # Match user_assignments to their assignment
      if student.user_assignments != undefined
        for user_assignment in student.user_assignments
          assignment = _.find(org.assignments, (a) -> user_assignment.assignment_id == a.id)
          user_assignment.title = assignment.title
          user_assignment.due_datetime = assignment.due_datetime
          user_assignment.description = assignment.description
          user_assignment.assigner = assignment.user
          user_assignment.user = student
          assignment.user_assignments.push(user_assignment)

      # Add up student's gpa
      # TODO This isn't the correct way to calculate gpa
      student.total_gpa = 0.0
      student.semester_gpa = 0.0
      if !!student.user_gpas && student.user_gpas.length > 0
        _.each(student.user_gpas, (gpa) -> student.total_gpa += gpa.regular_unweighted)
        student.total_gpa /= student.user_gpas.length
      semester_gpa = _.findWhere(student.user_gpas, {time_unit_id: time_unit_id})
      if semester_gpa
        if semester_gpa.regular_unweighted > 0
          student.semester_gpa = semester_gpa.regular_unweighted
        else
          org.gpa_student_count += 1
      else
        org.gpa_student_count += 1

      org.total_gpa += student.total_gpa
      org.semester_gpa += student.semester_gpa

      # Add up student's service hours
      student.total_service_hours = student.semester_service_hours = 0
      _.each(student.user_service_hours, (ush) ->
        student.total_service_hours += parseFloat(ush.hours)
        student.semester_service_hours += if ush.time_unit_id == time_unit_id then parseFloat(ush.hours) else 0
      )
      org.total_serviceHours += student.total_service_hours
      org.semester_serviceHours += student.semester_service_hours

      # Add up student's activities
      student.total_extracurricular_activities =\
        if student.user_extracurricular_activity_details then student.user_extracurricular_activity_details.length else 0
      student.semester_extracurricular_activities =\
        _.filter(student.user_extracurricular_activity_details, (detail) -> detail.time_unit_id == time_unit_id).length
      org.total_ecActivities += student.total_extracurricular_activities
      org.semester_ecActivities += student.semester_extracurricular_activities

      # Add up student's tests
      student.total_tests = if student.user_tests then student.user_tests.length else 0
      student.semester_tests = _.filter(student.user_tests, (test) -> test.time_unit_id == time_unit_id).length
      org.total_testsTaken += student.total_tests
      org.semester_testsTaken += student.semester_tests

      # Determine if student needs attention
      student.needs_attention = _.some(student.user_expectations, (ue) -> ue.status == 2)
      if student.needs_attention
        org.attention_studentIds.push(student.id)

      student.meeting_expectations = _.every(student.user_expectations, (ue) -> ue.status == 0)

    # Perform averaging calculations
    # XXX: not correct for gpa (could include a student in count, but their gpa is 0)
    num_students = org.students.length
    if num_students > 0
      org.average_gpa = (org.semester_gpa / (num_students - org.gpa_student_count)).toFixed(2)
      org.average_serviceHours = (org.semester_serviceHours / num_students).toFixed(2)
      org.average_ecActivities = (org.semester_ecActivities / num_students).toFixed(2)
      org.average_testsTaken = (org.semester_testsTaken / num_students).toFixed(2)

    org.groupedStudents = _.groupBy(org.students, "class_of")

    return org


  @ #  Returns 'this', otherwise it'll return the last function
]
