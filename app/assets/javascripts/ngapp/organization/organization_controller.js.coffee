angular.module('myApp')
.controller 'OrganizationCtrl', ['$scope', '$modal', '$route', 'current_user', 'UsersService', 'ProgressService', 'ExpectationService',
  'OrganizationService',
  ($scope, $modal, $route, current_user, UsersService, ProgressService, ExpectationService, OrganizationService) ->

    $scope.mentor_needs_help = "1*"

    $scope.active_user_threshold = (new Date()).getTime() - (1000*60*60*24*7) # One week ago

    $scope._ = _

    $scope.current_user = current_user # Set by parent dashboard
    #$scope.user = user # Set by parent dashboard
    $scope.current_organization = $scope.current_user.organization_name
    $scope.organization = null
    $scope.groupedStudents = []
    $scope.org_milestones = {}

    $scope.active_mentors = ""
    $scope.active_students = ""

    $scope.total_gpa = $scope.semester_gpa = 0
    $scope.total_serviceHours = $scope.semester_serviceHours = 0
    $scope.total_ecActivities = $scope.semester_ecActivities = 0
    $scope.total_testsTaken = $scope.testsTaken = 0

    $scope.average_gpa = ""
    $scope.average_serviceHours = ""
    $scope.average_ecActivities = ""
    $scope.average_testsTaken = ""

    $('input, textarea').placeholder()

    OrganizationService.getOrganizationWithUsers($route.current.params.id)
      .success (data) ->
        $scope.organization = data.organization

        $scope.organization.students = _.where($scope.organization.users, { role: 50 })
        $scope.organization.mentors = _.where($scope.organization.users, { role: 40 })
        $scope.organization.orgAdmins = _.where($scope.organization.users, { role: 10 })

        $scope.active_students = _.filter($scope.organization.students, (student) -> (new Date(student.last_login)).getTime() >= $scope.active_user_threshold).length
        $scope.active_mentors = _.filter($scope.organization.mentors, (mentor) -> (new Date(mentor.last_login)).getTime() >= $scope.active_user_threshold).length

        # Sort org_milestones by time_unit_id and module, while tallying up total points
        for time_unit, org_milestones_by_time_unit of _.groupBy($scope.organization.milestones, "time_unit_id")
          $scope.org_milestones[time_unit.toString()] = {}
          for module_title, org_milestones_by_module of _.groupBy(org_milestones_by_time_unit, "module")
            $scope.org_milestones[time_unit.toString()][module_title] = org_milestones_by_module
            $scope.org_milestones[time_unit.toString()][module_title].totalPoints = 0
            for org_milestone in $scope.org_milestones[time_unit.toString()][module_title]
              $scope.org_milestones[time_unit.toString()][module_title].totalPoints += org_milestone.points

        for student in $scope.organization.students
          # Find the student's mentors
          student.mentors = []
          for mentor_id in _.uniq(_.pluck(student.relationships, "assigned_to_id"))
            student.mentors.push(_.findWhere($scope.organization.mentors, { id: mentor_id }))

          # Calculate progress for each module
          for module_title, org_milestones_by_module of $scope.org_milestones[student.time_unit_id]
            new_module_progress = { module_title: module_title, time_unit_id: student.time_unit_id,\
                                    points: { user: 0, total: org_milestones_by_module.totalPoints } }
            for user_milestone in _.where(student.user_milestones, { time_unit_id: student.time_unit_id, module: module_title } )
              org_milestone = _.findWhere(org_milestones_by_module, { id: user_milestone.milestone_id } )
              if org_milestone
                new_module_progress.points.user += org_milestone.points
              else
                console.log("Error: user_milestone has no matching org_milestone.", user_milestone, org_milestones_by_module, $scope.org_milestones)
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

          # Add up student's gpa
          # TODO This isn't the correct way to calculate gpa
          student.user_classes.total_gpa = student.user_classes.semester_gpa = 0.0
          _.each(student.user_classes, (user_class) ->
            student.user_classes.total_gpa += parseFloat(user_class.gpa)
            student.user_classes.semester_gpa += if user_class.time_unit_id == student.time_unit_id then parseFloat(user_class.gpa) else 0
          )
          student.user_classes.total_gpa /= student.user_classes.length
          student.user_classes.semester_gpa /= _.filter(student.user_classes, (user_class) -> user_class.time_unit_id == student.time_unit_id ).length
          $scope.total_gpa += student.user_classes.total_gpa
          $scope.semester_gpa += student.user_classes.semester_gpa

          # Add up student's service hours
          student.user_service_hours.total_hours = student.user_service_hours.semester_hours = 0
          _.each(student.user_service_hours, (ush) ->
            student.user_service_hours.total_hours += parseFloat(ush.hours)
            student.user_service_hours.semester_hours += if ush.time_unit_id == student.time_unit_id then parseFloat(ush.hours) else 0
          )
          $scope.total_serviceHours += student.user_service_hours.total_hours
          $scope.semester_serviceHours += student.user_service_hours.semester_hours

          # Add up student's activities
          student.user_extracurricular_activity_details.total_activities =\
            student.user_extracurricular_activity_details.length
          student.user_extracurricular_activity_details.semester_activities =\
            _.filter(student.user_extracurricular_activity_details, (detail) ->
              detail.time_unit_id == student.time_unit_id).length
          $scope.total_ecActivities += student.user_extracurricular_activity_details.total_activities
          $scope.semester_ecActivities += student.user_extracurricular_activity_details.semester_activities

          # Add up student's tests
          student.user_tests.total_tests = student.user_tests.length
          student.user_tests.semester_tests =\
            _.filter(student.user_tests, (test) ->
              test.time_unit_id == student.time_unit_id).length
          $scope.total_testsTaken += student.user_tests.total_tests
          $scope.semester_testsTaken += student.user_tests.semester_tests

          # Determine if student needs attention
          student.needs_attention = if _.findWhere(student.user_expectations, { status: 2 } ) then true else false

        # Perform averaging calculations
        num_students = $scope.organization.students.length
        $scope.average_gpa = "3.14" # $scope.semester_gpa / num_students
        $scope.average_serviceHours = ($scope.semester_serviceHours / num_students).toFixed(2)
        $scope.average_ecActivities = ($scope.semester_ecActivities / num_students).toFixed(2)
        $scope.average_testsTaken = ($scope.semester_serviceHours / num_students).toFixed(2)

        $scope.groupedStudents = _.groupBy($scope.organization.students, "class_of")
        $scope.loaded_users = true

    $scope.fullName = (user) ->
      if user.id == current_user.id
        "Me"
      else
        user.first_name + " " + user.last_name

    $scope.addStudent = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newStudent($scope.organization.id)

      modalInstance.result.then (user) ->
        $scope.organization.students.push(user)
        $scope.groupedStudents = _.groupBy($scope.organization.students, "class_of")

    $scope.addMentor = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newMentor($scope.organization.id)

      modalInstance.result.then (user) ->
        $scope.organization.mentors.push(user)

]
