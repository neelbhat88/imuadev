angular.module 'myApp'
.controller 'AddUserModalController', ['$scope', '$modalInstance', 'current_user', 'organization', 'new_user', 'UsersService', 'LoadingService',
  ($scope, $modalInstance, current_user, organization, new_user, UsersService, LoadingService) ->
    $scope.formErrors = [ '**Please fix the errors above**' ]
    $scope.current_user = current_user
    $scope.user = new_user
    $scope.organization = organization

    $scope.add = () ->
      $scope.formErrors = []
      laddaElement = $(".ladda-button").get(0)

      if $scope.formErrors.length == 0
        LoadingService.buttonStart(laddaElement)
        UsersService.addUser($scope.user)
          .success (data) ->
            $modalInstance.close(data.user)

          .error (data) ->
            $scope.formErrors.push(data.info)
            $scope.newUserForm.$invalid = true
            $scope.newUserForm.$submitted = true

          .finally ()->
            LoadingService.buttonStop()

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

]
