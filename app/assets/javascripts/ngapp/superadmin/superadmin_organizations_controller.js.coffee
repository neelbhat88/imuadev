angular.module('myApp')
.controller 'SuperAdminOrganizationsCtrl', ['$scope', 'current_user', 'OrganizationService',
  ($scope, current_user, OrganizationService) ->
    $scope.user = current_user

    OrganizationService.all()
      .success (data) ->
        $scope.organizations = data.organizations

    $scope.addOrganization = (name) ->
      OrganizationService.addOrganization(name)
        .success (data) ->
          $scope.organizations.push(data.organization)
          $scope.newOrg.name = ""
]
