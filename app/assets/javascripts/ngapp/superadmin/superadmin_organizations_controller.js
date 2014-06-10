angular.module('myApp')
.controller('SuperAdminOrganizationsCtrl', ['$scope', 'current_user', 'OrganizationService',
  function($scope, current_user, OrganizationService) {
    $scope.user = current_user;

    OrganizationService.all().then(
      function Success(data) {
        $scope.organizations = data.organizations;
      }
    );
  }
]);