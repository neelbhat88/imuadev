angular.module('myApp')
.controller('ProfileController', ['$scope', 'current_user', 'UsersService', 'LoadingService',
  function($scope, current_user, UsersService, LoadingService) {

    $scope.user = current_user;
    $scope.origUser = angular.copy($scope.user)
    $scope.editingInfo = false;
    $scope.editingPassword = false;
    $scope.password = {current: "", new: "", confirm: ""};

    $scope.editing = function() {
      return $scope.editingInfo || $scope.editingPassword;
    };

    $scope.editUserInfo = function() {
      $scope.editingInfo = true;
    };

    $scope.cancelUpdateUserInfo = function() {
      $scope.files = null;
      $('.js-upload')[0].value = ""; // sort of hacky but it'll do for now
      $scope.user = angular.copy($scope.origUser);
      $scope.editingInfo = false;
      $scope.errors = {};
    };

    $scope.updateUserInfo = function($event) {

      var fd = new FormData();
      angular.forEach($scope.files, function(file) {
        fd.append('user[avatar]', file);
      });

      LoadingService.buttonStart($event.currentTarget);
      UsersService.updateUserInfoWithPicture($scope.user, fd)
        .success(function(data) {
          // ToDo: Success message here
          $scope.user = data.user;

          $scope.files = null;
          $('.js-upload')[0].value = ""; // sort of hacky but it'll do for now
          $scope.editingInfo = false;
          $scope.origUser = angular.copy($scope.user);
          $scope.errors = {};
        })
        .error(function(data) {
          $scope.errors = data.info;

          // ToDo: Error message here
        })
        .finally(function() {
          LoadingService.buttonStop();
        });

    };

    $scope.editUserPassword = function() {
      $scope.editingPassword = true;
    };

    $scope.cancelUpdatePassword = function() {
      $scope.editingPassword = false;
      clearPasswordFields();
    };

    $scope.updateUserPassword = function($event) {
      $scope.errors = [];
      if (!$scope.password.current || !$scope.password.new || !$scope.password.confirm)
      {
        $scope.errors.push("You must fill in all fields.");
        return;
      }

      LoadingService.buttonStart($event.currentTarget);
      UsersService.updateUserPassword($scope.user, $scope.password)
        .success(function(data) {
          //ToDo: Add Success message here
          clearPasswordFields();
          $scope.editingPassword = false;
        })
        .error(function(data) {
          $scope.errors = [];
          $scope.errors = data.info;
        })
        .finally(function(){
          LoadingService.buttonStop();
        });
    };

    function clearPasswordFields()
    {
      $scope.password = {};
      $scope.errors = [];
    }

  }

]);