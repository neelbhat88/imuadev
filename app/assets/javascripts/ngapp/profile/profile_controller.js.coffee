angular.module('myApp')
.controller 'ProfileController', ['$scope', 'user_with_contacts', 'UsersService', 'LoadingService',
($scope, user_with_contacts, UsersService, LoadingService) ->
  $scope.user = user_with_contacts.user
  $scope.contacts = user_with_contacts.contacts
  $scope.time_units = user_with_contacts.time_units
  $scope.origUser = angular.copy($scope.user)
  $scope.editingInfo = false
  $scope.editingPassword = false
  $scope.editingParentGuardianContacts = false
  $scope.password = {current: "", new: "", confirm: ""}
  $scope.student_mentors = []
  $scope.errors = [ '**Please fix the errors above**' ]

  $scope.editing = () ->
    $scope.editingInfo || $scope.editingPassword

  $scope.editable = () ->
    $scope.current_user.role != $scope.CONSTANTS.USER_ROLES.student ||
    $scope.current_user.id == $scope.user.id

  $scope.editablePassword = () ->
    $scope.current_user.id == $scope.user.id

  $scope.editUserInfo = () ->
    $scope.editingInfo = true

  $scope.cancelUpdateUserInfo = () ->
    $scope.files = null
    $('.js-upload')[0].value = "" # sort of hacky but it'll do for now
    $scope.user = angular.copy($scope.origUser)
    $scope.editingInfo = false
    $scope.errors = [ '**Please fix the errors above**' ]

  $scope.updateUserInfo = ($event) ->
    if $scope.user.title == null # hack for title
      $scope.user.title = ''

    fd = new FormData()
    angular.forEach $scope.files, (file) ->
      fd.append('user[avatar]', file)

    laddaElement = $(".ladda-button").get(0)
    LoadingService.buttonStart(laddaElement)

    UsersService.updateUserInfoWithPicture($scope.user, fd)
      .success (data) ->
        # ToDo: Success message here
        $scope.user = data.user


        $scope.files = null
        $('.js-upload')[0].value = "" #sort of hacky but it'll do for now
        $scope.editingInfo = false
        $scope.origUser = angular.copy($scope.user)
        $scope.addSuccessMessage("Profile info updated successfully!")

      .error (data) ->
        $scope.errors = data.info
        $scope.profileForm.$invalid = true
        $scope.profileForm.$submitted = true
        $scope.addErrorMessage("Profile info was not updated")

        #ToDo: Error message here

      .finally () ->
        LoadingService.buttonStop()

  $scope.editUserPassword = () ->
    $scope.errors = []
    $scope.editingPassword = true

  $scope.cancelUpdatePassword = () ->
    $scope.editingPassword = false
    clearPasswordFields()

  $scope.updateUserPassword = ($event) ->
    $scope.errors = []
    if !$scope.password.current || !$scope.password.new || !$scope.password.confirm
      $scope.errors.push("You must fill in all fields.")
      return

    LoadingService.buttonStart($event.currentTarget)
    UsersService.updateUserPassword($scope.user, $scope.password)
      .success (data) ->
        #ToDo: Add Success message here
        clearPasswordFields()
        $scope.editingPassword = false

      .error (data) ->
        $scope.errors = []
        $scope.errors = data.info

      .finally () ->
        LoadingService.buttonStop()

  clearPasswordFields = () ->
    $scope.password = {}
    $scope.errors = []

  $scope.editParentGuardianContact = (index) ->
    $scope.contacts[index].editing = true
    $scope.editingParentGuardianContacts = true
    $scope.contacts[index].new_name = $scope.contacts[index].name
    $scope.contacts[index].new_relationship = $scope.contacts[index].relationship
    $scope.contacts[index].new_email = $scope.contacts[index].email
    $scope.contacts[index].new_phone = $scope.contacts[index].phone

  $scope.cancelEditParentGuardianContact = (index) ->
    if $scope.contacts[index].id
      $scope.contacts[index].editing = false
    else
      $scope.contacts.splice(index, 1)
    $scope.editingParentGuardianContacts = false

  $scope.saveParentGuardianContact = (index) ->
    new_parentGuardianContact = UsersService.newParentGuardianContact($scope.user.id)
    new_parentGuardianContact.id = $scope.contacts[index].id
    new_parentGuardianContact.user_id = $scope.contacts[index].user_id
    new_parentGuardianContact.name = $scope.contacts[index].new_name
    new_parentGuardianContact.relationship = $scope.contacts[index].new_relationship
    new_parentGuardianContact.email = $scope.contacts[index].new_email
    new_parentGuardianContact.phone = $scope.contacts[index].new_phone

    UsersService.saveParentGuardianContact(new_parentGuardianContact)
     .success (data) ->
       $scope.contacts[index] = data.parent_guardian_contact
       $scope.contacts[index].editing = false
       $scope.editingParentGuardianContacts = false

  $scope.deleteParentGuardianContact = (index) ->
    if window.confirm "Are you sure you want to delete this contact?"
      UsersService.deleteParentGuardianContact($scope.contacts[index])
        .success (data) ->
          $scope.contacts.splice(index, 1)

  $scope.addParentGuardianContact = () ->
    $scope.editingParentGuardianContacts = true
    blank_contact = UsersService.newParentGuardianContact($scope.user.id)
    blank_contact.editing = true
    $scope.contacts.push(blank_contact)

  $scope.loaded_student_mentors = false
  UsersService.getAssignedMentors($scope.user.id)
    .success (data) ->
      $scope.student_mentors = data.mentors
      $scope.loaded_student_mentors = true

]
