angular.module('myApp', ['ngRoute', 'myApp.controllers', 'myApp.services', 'myApp.directives'])

.config(['$routeProvider', '$locationProvider',
  function($routeProvider, $locationProvider) {

    $routeProvider.when('/', {
      templateUrl: '/assets/roadmap.html',
      controller: 'RoadmapController',
      resolve: {      
        currentUser: ['SessionService', function(SessionService) {
          return SessionService.getCurrentUser();
        }]
      },
      redirectTo: function(current, path, search){
        if(search.goto){
          // if we were passed in a search param, and it has a path
          // to redirect to, then redirect to that path
          return "/" + search.goto
        }
        else{
          // else just redirect back to this location
          // angular is smart enough to only do this once.
          return "/"
        }
      }
    })
    
    .when('/profile', {
      templateUrl: '/assets/profile.html',
      controller: 'ProfileController'     
    })
    
    .otherwise({redirectTo: '/'});

    $locationProvider.html5Mode(true); // Removes the /#/ from the URL
  }
]);

// HTTP statuses used by Rest calls
var Status = new function() {
  this.Success = 200;

  this.Error = 500;
}