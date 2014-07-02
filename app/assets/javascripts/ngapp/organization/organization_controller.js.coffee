angular.module('myApp')
.controller 'OrganizationCtrl', ['$scope', '$routeParams', '$location',
                                  '$modal', 'current_user', 'OrganizationService', 'UsersService',
  ($scope, $routeParams, $location, $modal, current_user, OrganizationService, UsersService) ->
    orgId = $routeParams.id
    $scope.current_user = current_user
    $scope.userCtrl = current_user

    $('input, textarea').placeholder();

    # Question: Can this be done in the resolve instead?
    OrganizationService.getOrganization($routeParams.id)
      .success (data) ->
        $scope.organization = data.organization

      .error (data) ->
        $location.path('/')

    $scope.fullName = (user) ->
      if user.id == current_user.id
        "Me"
      else
        user.first_name + " " + user.last_name;

    $scope.addOrgAdmin = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newOrgAdmin($scope.organization.id);

      modalInstance.result.then (user) ->
        $scope.organization.orgAdmins.push(user)

    $scope.addStudent = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newStudent($scope.organization.id);

      modalInstance.result.then (user) ->
        $scope.organization.students.push(user)

    $scope.addMentor = () ->
      modalInstance = $modal.open
        templateUrl: 'organization/add_user_modal.html',
        controller: 'AddUserModalController',
        backdrop: 'static',
        size: 'sm',
        resolve:
          organization: () -> $scope.organization
          new_user: () -> UsersService.newMentor($scope.organization.id);

      modalInstance.result.then (user) ->
        $scope.organization.mentors.push(user)

]
