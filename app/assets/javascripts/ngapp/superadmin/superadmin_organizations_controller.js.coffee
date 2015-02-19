angular.module('myApp')
.controller 'SuperAdminOrganizationsCtrl', ['$scope', 'OrganizationService',
  ($scope, OrganizationService) ->
    $scope.user = $scope.current_user

    OrganizationService.all()
      .success (data) ->
        $scope.organizations = data.organizations

    $scope.addOrganization = (name) ->
      OrganizationService.addOrganization(name)
        .success (data) ->
          $scope.organizations.push(data.organization)
          $scope.newOrg.name = ""
]
