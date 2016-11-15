angular.module('myApp')
.controller 'SuperAdminOrganizationsCtrl', ['$scope', 'OrganizationService',
  ($scope, OrganizationService) ->
    $scope.user = $scope.current_user
    $scope.formErrors = ['** Please fix all the errors **']

    OrganizationService.all()
      .success (data) ->
        $scope.organizations = data.organizations

    $scope.addOrganization = (name) ->
      $scope.formErrors = ['** Please fix all the errors **']
      OrganizationService.addOrganization(name)
        .success (data) ->
          $scope.organizations.push(data.organization)
          $scope.newOrg.name = ""
          $scope.newOrg.form.$setPristine()
        .error (data) ->
          $scope.formErrors.push(data.info)
          $scope.newOrg.form.$invalid = true
          $scope.newOrg.form.$submitted = true
]
