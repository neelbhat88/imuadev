angular.module('myApp', ['ngRoute', 'myApp.controllers', 'myApp.services',
                          'myApp.directives', 'ui.bootstrap'])

.config(['$routeProvider', 'USER_ROLES',
  function($routeProvider, USER_ROLES) {

    $routeProvider.when('/', {
      templateUrl: '/assets/roadmap/roadmap.tmpl.html',
      controller: 'RoadmapController',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      }
    })

    .when('/sa/organizations', {
      templateUrl: '/assets/superadmin/organizations.tmpl.html',
      controller: 'SuperAdminOrganizationsCtrl',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      },
      data: {
        authorizedRoles: [USER_ROLES.super_admin]
      }
    })

    .when('/organization/:id', {
      templateUrl: '/assets/organization/organization.tmpl.html',
      controller: 'OrganizationCtrl',
      resolve: {
        current_user: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      },
      data: {
        authorizedRoles: [USER_ROLES.super_admin, USER_ROLES.org_admin]
      }
    })

    .otherwise({redirectTo: '/'});
  }
]);

angular.module('myApp')
.run(['$rootScope', '$location', 'SessionService', function($rootScope, $location, SessionService){
  $rootScope.$on('$routeChangeStart', function(event, next, current){
    // If no authorized roles than the route is authorized for everyone
    if ( next.data && next.data.authorizedRoles )
    {
      var authorizedRoles = next.data.authorizedRoles;

      if (!SessionService.isAuthorized(authorizedRoles)) {
        $location.path('/');
        return false;
      }
    }

    return true;
  });
}]);