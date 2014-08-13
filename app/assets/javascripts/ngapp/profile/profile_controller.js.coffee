angular.module('myApp')
.controller 'ProfileController', ['$scope', 'current_user', 'user', 'UsersService', 'LoadingService',
($scope, current_user, user, UsersService, LoadingService) ->
  $scope.user = user
  $scope.origUser = angular.copy($scope.user)
  $scope.editingInfo = false
  $scope.editingPassword = false
  $scope.password = {current: "", new: "", confirm: ""}

  $scope.editing = () ->
    $scope.editingInfo || $scope.editingPassword

  $scope.editable = () ->
    current_user.role != $scope.CONSTANTS.USER_ROLES.student ||
    current_user.id == user.id

  $scope.editablePassword = () ->
    current_user.id == $scope.user.id

  $scope.editUserInfo = () ->
    $scope.editingInfo = true

  $scope.cancelUpdateUserInfo = () ->
    $scope.files = null
    $('.js-upload')[0].value = "" # sort of hacky but it'll do for now
    $scope.user = angular.copy($scope.origUser)
    $scope.editingInfo = false
    $scope.errors = {}

  $scope.updateUserInfo = ($event) ->
    fd = new FormData()
    angular.forEach $scope.files, (file) ->
      fd.append('user[avatar]', file)

    LoadingService.buttonStart($event.currentTarget)
    UsersService.updateUserInfoWithPicture($scope.user, fd)
      .success (data) ->
        # ToDo: Success message here
        $scope.user = data.user

        $scope.files = null
        $('.js-upload')[0].value = "" #sort of hacky but it'll do for now
        $scope.editingInfo = false
        $scope.origUser = angular.copy($scope.user)
        $scope.errors = {}

      .error (data) ->
        $scope.errors = data.info

        #ToDo: Error message here

      .finally () ->
        LoadingService.buttonStop()

  $scope.editUserPassword = () ->
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

]
