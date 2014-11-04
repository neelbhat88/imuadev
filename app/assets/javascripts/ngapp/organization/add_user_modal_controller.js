angular.module('myApp')
.controller('AddUserModalController', ['$scope', '$modalInstance', 'organization', 'new_user', 'UsersService', 'LoadingService',
  function($scope, $modalInstance, organization, new_user, UsersService, LoadingService) {
    $scope.formErrors = [ '**Please fix the errors above**' ];
    $scope.user = new_user;
    $scope.class_of = [
      {name: '-- Graduating Class --', value: null},
      {name: 'Class of 2014', value: 2014},
      {name: 'Class of 2015', value: 2015},
      {name: 'Class of 2016', value: 2016},
      {name: 'Class of 2017', value: 2017},
      {name: 'Class of 2018', value: 2018},
      {name: 'Class of 2019', value: 2019},
      {name: 'Class of 2020', value: 2020}
    ]

    $scope.add = function($event)
    {
      $scope.formErrors = [];

      if ($scope.formErrors.length == 0)
      {
        LoadingService.buttonStart($event.currentTarget);
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
