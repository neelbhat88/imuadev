angular.module('myApp')
.controller 'MentorController', ['$scope', 'current_user', 'user', 'UsersService', 'ProgressService', 'OrganizationService',
($scope, current_user, user, UsersService, ProgressService, OrganizationService) ->

  $scope.all_students = []
  $scope.current_user = current_user
  $scope.mentor = user
  $scope.assigned_students = []
  $scope.attention_students = []

  load_users = () ->
    OrganizationService.getOrganizationWithUsers($scope.mentor.organization_id)
    .success (data) ->
      $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
      user_mentor = _.find($scope.organization.mentors, (mentor) -> mentor.id == $scope.mentor.id)
      if user_mentor
        $scope.assigned_students = _.filter($scope.organization.students, (student) -> _.contains(user_mentor.studentIds, student.id))
        $scope.attention_students = _.where($scope.assigned_students, { needs_attention: true })
      $scope.all_students = $scope.organization.students
      $scope.loaded_users = true

  load_users()

  $scope.assign = (student) ->
    # TODO Return object from "assign" should be a ViewUser with all the data
    #      so that a new load_users call doesn't have to be made afterwards.
    #      Question is, how to efficiently re-parse needs_attention for the
    #      single ViewUser.
    UsersService.assign($scope.mentor.id, student.id)
      .success (data) ->
        load_users()

  $scope.unassign = (student) ->
    UsersService.unassign($scope.mentor.id, student.id)
      .success (data) ->
        for a_student, index in $scope.assigned_students
          if a_student.id == student.id
            $scope.assigned_students.splice(index, 1)
            break;
        for a_student, index in $scope.attention_students
          if a_student.id == student.id
            $scope.attention_students.splice(index, 1)
            break;

  $scope.isAssigned = (student) ->
    assigned = false
    for s in $scope.assigned_students
      if student.id == s.id
        assigned = true
        break

    return assigned
]
