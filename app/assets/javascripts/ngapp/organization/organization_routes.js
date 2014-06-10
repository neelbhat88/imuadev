angular.module('myApp')
.config(['$routeProvider', 'CONSTANTS',
  function($routeProvider, CONSTANTS) {

    $routeProvider.when('/organization/:id', {
      templateUrl: '/assets/organization/organization.tmpl.html',
      controller: 'OrganizationCtrl',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      },
      data: {
        authorizedRoles: [CONSTANTS.USER_ROLES.super_admin, CONSTANTS.USER_ROLES.org_admin]
      }
    });

  }
]);