angular.module('myApp.controllers', [])

.controller('SuperAdminOrganizationsCtrl', ['$scope', 'SessionService', 'OrganizationService',
  function($scope, SessionService, OrganizationService) {
    var currentUser = SessionService.currentUser;

    OrganizationService.all().then(
      function Success(data) {
        $scope.organizations = data.organizations;
      }
    );
  }
])

.controller('OrganizationCtrl', ['$scope', '$routeParams', '$location',
                                  '$modal', 'OrganizationService',
  function($scope, $routeParams, $location, $modal, OrganizationService) {
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

    $scope.addOrgAdmin = function(){
      var modalInstance = $modal.open({
        templateUrl: 'addUserModal.tmpl.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve: {
          organization: function() {
            return $scope.organization;
          }
        }
      });

      modalInstance.result.then(function (user){
        $scope.organization.orgAdmins.push(user);
      });
    }
  }
])

.controller('AddUserModalController', ['$scope', '$modalInstance', 'organization', 'UsersService', 'LoadingService',
  function($scope, $modalInstance, organization, UsersService, LoadingService) {
    $scope.errors = [];
    $scope.user = UsersService.newOrgAdmin(organization.id);

    $scope.add = function($event)
    {
      $scope.errors = [];

      if ($scope.user.email == "")
        $scope.errors.push("You must provide an email.");

      if ($scope.errors.length == 0)
      {
        LoadingService.buttonStart($event.currentTarget);
        UsersService.addUser($scope.user).then(
          function Success(data){
            $modalInstance.close(data.user);
          },
          function Error(data){
            $scope.errors = [data.info]
          }
        )
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