angular.module('myApp')
.controller 'NavController', ['$scope', 'Auth',
  ($scope, Auth) ->
    $scope.$on 'devise:logout', (event, oldCurrentUser) ->
      $('#wrapper').removeClass('toggled')

    $scope.logout = () ->
      Auth.logout()

]
