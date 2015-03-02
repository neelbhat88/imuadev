angular.module('myApp')
.controller 'LoginController', ['$rootScope', '$scope', '$location', 'Auth', 'UsersService',
  ($rootScope, $scope, $location, Auth, UsersService) ->
    $rootScope.hide_nav = true

    $scope.forgot_password = false

    Auth.logout()

    $scope.forgotPassword = () ->
      $scope.forgot_password = true

    $scope.backToLogin = () ->
      $scope.forgot_password = false

    $scope.login = (user) ->
      Auth.login(user).then (user) ->
        $rootScope.hide_nav = false

        previous_url = $location.search().pu
        if previous_url
          $location.path(previous_url)
          $location.url($location.path()) # Clears the query params
        else
          $location.path('/')

      , (error) ->
        $scope.addErrorMessage(error.data.error)

    $scope.resetPassword  = (user) ->
      UsersService.resetPassword(user).then (response) ->
        $scope.forgot_password = false
        $scope.addSuccessMessage(response.data.message)
      , (response) ->
        $scope.addErrorMessage(response.data.message)

]
