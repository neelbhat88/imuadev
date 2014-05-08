angular.module('myApp', ['ngRoute', 'ngResource', 'myApp.controllers', 'myApp.services'])

.config(['$routeProvider', 
	function($routeProvider) {

	$routeProvider.when('/', {
		templateUrl: '/assets/profile.html',
		controller: 'ProfileController',
		resolve: {
			session: function(SessionService) {
				return SessionService.getCurrentUser();
			}
		}
	})
	.otherwise({redirectTo: '/'});

}]);