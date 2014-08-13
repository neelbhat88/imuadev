angular.module('myApp')
.controller('AddUserModalController', ['$scope', '$modalInstance', 'organization', 'new_user', 'UsersService', 'LoadingService',
  function($scope, $modalInstance, organization, new_user, UsersService, LoadingService) {
    $scope.errors = [];
    $scope.user = new_user;

    $scope.add = function($event)
    {
      $scope.errors = [];

      if ($scope.user.email == "")
        $scope.errors.push("You must provide an email.");

      if ($scope.errors.length == 0)
      {
        LoadingService.buttonStart($event.currentTarget);
        UsersService.addUser($scope.user)
          .success(function(data) {
            $modalInstance.close(data.user);
          })
          .error(function(data) {
            $scope.errors = [data.info]
          })
          .finally(function(){
            LoadingService.buttonStop();
          });
      }
    };

    $scope.cancel = function() {
      $modalInstance.dismiss('cancel');
    };

  }
]);