angular.module('myApp', ['ngRoute', 'myApp.controllers',
                          'myApp.directives', 'ui.bootstrap', 'templates']);

angular.module('myApp')
.controller('AppController', ['$scope', 'CONSTANTS', function($scope, CONSTANTS){
  $scope.CONSTANTS = CONSTANTS;
}]);

angular.module('myApp')
.run(['$rootScope', '$location', 'SessionService', function($rootScope, $location, SessionService){

  $rootScope.$on('$routeChangeStart', function(event, next, current) {
    // Always calling getCurrentUser on every change/refresh to make sure current_user is set
    SessionService.getCurrentUser().then(function(){
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
  });
}]);
