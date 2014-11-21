angular.module('myApp')
.controller 'ActivityController', ['$scope', 'current_user', 'activity', 'ActivityService',
($scope, current_user, activity, ActivityService) ->

  $scope.current_user = current_user
  $scope.activity = activity

  $('input, textarea').placeholder()


]
