angular.module('myApp')
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
]);