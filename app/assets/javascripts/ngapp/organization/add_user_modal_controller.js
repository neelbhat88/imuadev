angular.module('myApp')
.controller('AddUserModalController', ['$scope', '$modalInstance', 'organization', 'new_user', 'UsersService', 'LoadingService',
  function($scope, $modalInstance, organization, new_user, UsersService, LoadingService) {
    $scope.formErrors = [ '**Please fix the errors above**' ];
    $scope.user = new_user;

    $scope.add = function()
    {
      $scope.formErrors = [];
      var laddaElement = $(".ladda-button").get(0);
      console.log(laddaElement);

      if ($scope.formErrors.length == 0)
      {
        LoadingService.buttonStart(laddaElement);
        UsersService.addUser($scope.user)
          .success(function(data) {
            $modalInstance.close(data.user);
          })
          .error(function(data) {
            $scope.formErrors.push(data.info);
            $scope.newUserForm.$invalid = true;
            $scope.newUserForm.$submitted = true;

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
