angular.module('myApp')
.controller 'LoginController', ['$rootScope', '$scope', '$location', 'Auth',
  ($rootScope, $scope, $location, Auth) ->
    $rootScope.hide_nav = true

    Auth.logout()

    $scope.login = (user) ->
      Auth.login(user).then (user) ->
        $rootScope.hide_nav = false
        $location.path('/')
      , (error) ->
        $scope.addErrorMessage(error.data.error)

]
