angular.module('myApp.controllers', [])

.controller('SuperAdminOrganizationsCtrl', ['$scope', 'current_user', 'OrganizationService',
  function($scope, current_user, OrganizationService) {
    $scope.user = current_user;

    OrganizationService.all().then(
      function Success(data) {
        $scope.organizations = data.organizations;
      }
    );
  }
])

.controller('OrganizationCtrl', ['$scope', '$routeParams', '$location',
                                  '$modal', 'OrganizationService', 'UsersService',
  function($scope, $routeParams, $location, $modal, OrganizationService, UsersService) {
    var orgId = $routeParams.id

    // Question: Can this be done in the resolve instead?
    OrganizationService.getOrganization($routeParams.id).then(
      function Success(data){
        $scope.organization = data.organization;
      },
      function Error(data){
        $location.path('/');
      }
    );

    $scope.addOrgAdmin = function() {
      var modalInstance = $modal.open({
        templateUrl: '/assets/organization/add_user_modal.tmpl.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve: {
          organization: function() {
            return $scope.organization;
          },
          new_user: function() {
            return UsersService.newOrgAdmin($scope.organization.id);
          }
        }
      });

      modalInstance.result.then(function (user){
        $scope.organization.orgAdmins.push(user);
      });
    };

    $scope.addStudent = function() {
      var modalInstance = $modal.open({
        templateUrl: '/assets/organization/add_user_modal.tmpl.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve: {
          organization: function() {
            return $scope.organization;
          },
          new_user: function() {
            return UsersService.newStudent($scope.organization.id);
          }
        }
      });

      modalInstance.result.then(function (user){
        $scope.organization.students.push(user);
      });
    }
  }
])

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
])

.controller('HeaderController', ['$scope', 'SessionService',
  function($scope, SessionService) {
    $scope.user = SessionService.currentUser; // ToDo: This is null, need to figure out why
  }
]);