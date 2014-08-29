angular.module('myApp')
.controller 'MentorController', ['$scope', 'current_user', 'user', 'UsersService', 'ProgressService', 'OrganizationService',
($scope, current_user, user, UsersService, ProgressService, OrganizationService) ->

  $scope.all_students = []
  $scope.current_user = current_user
  $scope.mentor = user
  $scope.assigned_students = []

  OrganizationService.getOrganizationWithUsers($scope.mentor.organization_id)
  .success (data) ->
    $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
    user_mentor = _.find($scope.organization.mentors, (mentor) -> mentor.id == $scope.mentor.id)
    if user_mentor
      $scope.assigned_students = _.filter($scope.organization.students, (student) -> _.contains(user_mentor.studentIds, student.id))
    $scope.all_students = $scope.organization.students
    $scope.loaded_users = true

  $scope.assign = (student) ->
    UsersService.assign($scope.mentor.id, student.id)
      .success (data) ->
        ProgressService.getAllModulesProgress(data.student, data.student.time_unit_id).then (student_with_modules_progress) ->
          $scope.assigned_students.unshift(student_with_modules_progress)

  $scope.unassign = (student) ->
    UsersService.unassign($scope.mentor.id, student.id)
      .success (data) ->
        for a_student, index in $scope.assigned_students
          if a_student.id == student.id
            $scope.assigned_students.splice(index, 1)
            break;

  $scope.isAssigned = (student) ->
    assigned = false
    for s in $scope.assigned_students
      if student.id == s.id
        assigned = true
        break

    return assigned
]
