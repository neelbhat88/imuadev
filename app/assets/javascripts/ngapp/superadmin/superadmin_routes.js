angular.module('myApp')
.config(['$routeProvider', 'CONSTANTS',
  function($routeProvider, CONSTANTS) {

    $routeProvider.when('/sa/organizations', {
      templateUrl: 'superadmin/organizations.html',
      controller: 'SuperAdminOrganizationsCtrl',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      },
      data: {
        authorizedRoles: [CONSTANTS.USER_ROLES.super_admin]
      }
    });

  }
]);