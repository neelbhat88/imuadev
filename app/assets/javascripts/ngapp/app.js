angular.module('myApp', ['ngRoute', 'myApp.controllers', 'myApp.services',
                          'myApp.directives', 'ui.bootstrap'])

.config(['$routeProvider', '$locationProvider',
  function($routeProvider, $locationProvider) {

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
      controller: 'SuperAdminOrganizationsCtrl'
    })

    .when('/organization/:id', {
      templateUrl: '/assets/organization/organization.tmpl.html',
      controller: 'OrganizationCtrl'
    })

    .otherwise({redirectTo: '/'});
  }
]);

// HTTP statuses used by Rest calls
var Status = new function() {
  this.Success = 200;

  this.Error = 500;
}