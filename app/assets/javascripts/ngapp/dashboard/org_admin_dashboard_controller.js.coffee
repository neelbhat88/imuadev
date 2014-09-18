angular.module('myApp')
.controller "OrgAdminDashboardController", ['$scope', 'OrganizationService',
($scope, OrganizationService) ->

  # $scope.current_user = current_user # Set by parent dashboard
  # $scope.user = user # Set by parent dashboard
  $scope.current_organization = $scope.current_user.organization_name

  $('input, textarea').placeholder()

  OrganizationService.getOrganizationWithUsers($scope.current_user.organization_id)
    .success (data) ->
      $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)

      $scope.groupedStudents = $scope.organization.groupedStudents
      $scope.org_milestones = $scope.organization.org_milestones

      $scope.active_mentors = $scope.organization.active_mentors
      $scope.active_students = $scope.organization.active_students

      $scope.total_gpa = $scope.organization.total_gpa
      $scope.semester_gpa = $scope.organization.semester_gpa
      $scope.total_serviceHours = $scope.organization.total_serviceHours
      $scope.semester_serviceHours = $scope.organization.semester_serviceHours
      $scope.total_ecActivities = $scope.organization.total_ecActivities
      $scope.semester_ecActivities = $scope.organization.semester_ecActivities
      $scope.total_testsTaken = $scope.organization.total_testsTaken
      $scope.semester_testsTaken = $scope.organization.semester_testsTaken

      $scope.average_gpa = $scope.organization.average_gpa
      $scope.average_serviceHours = $scope.organization.average_serviceHours
      $scope.average_ecActivities = $scope.organization.average_ecActivities
      $scope.average_testsTaken = $scope.organization.average_testsTaken

      if $scope.organization.students.length == 0
        $scope.percent_students_with_one_activity = 0
      else
        $scope.percent_students_with_one_activity =
          ((_.filter($scope.organization.students, (student) ->
              student.semester_extracurricular_activities > 0).length / $scope.organization.students.length) * 100).toFixed(0)

      $scope.loaded_users = true
]
