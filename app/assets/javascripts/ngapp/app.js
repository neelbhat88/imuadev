angular.module('myApp', ['ngRoute', 'myApp.controllers', 'myApp.services'])

.config(['$routeProvider', 
	function($routeProvider) {

	$routeProvider.when('/', {
		templateUrl: '/assets/profile.html',
		controller: 'ProfileController',
		resolve: {
			session: ['$http', function($http) {
				return $http.get('/api/v1/current_user').then(function(resp){
						return resp.data;
					});
			}//function(SessionService) {
			// 	return SessionService.getCurrentUser();
			// }
		]}
	})
	.otherwise({redirectTo: '/'});

}]);