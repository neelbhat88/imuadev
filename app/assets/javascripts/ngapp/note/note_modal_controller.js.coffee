angular.module('myApp')
.controller 'NoteModalController', ['$scope', '$modalInstance', 'CONSTANTS', 'current_user', 'user', 'organization_with_users', 'NoteService', 'OrganizationService'
($scope, $modalInstance, CONSTANTS, current_user, user, organization_with_users, NoteService, OrganizationService) ->
  $scope.notes = []
  $scope.user = user
  $scope.current_user = current_user



  # this is temporary until a better call is created to get all Org Admins and Mentors in an org
  if organization_with_users != null
    $scope.organization = organization_with_users
    $scope.mentors = $scope.organization.mentors
    $scope.orgAdmins = $scope.organization.orgAdmins
  else
    OrganizationService.getOrganizationWithUsers($scope.current_user.organization_id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.mentors = $scope.organization.mentors
        $scope.orgAdmins = $scope.organization.orgAdmins


  NoteService.getUserNotes($scope.user.id)
    .success (data) ->
      for note in data.notes
        if note.is_private && note.created_by == $scope.current_user.id
          $scope.notes.push(note)
        else if !note.is_private
          $scope.notes.push(note)
]
