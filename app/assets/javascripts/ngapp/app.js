angular.module('myApp', ['ngRoute', 'myApp.controllers', 'myApp.services', 'myApp.directives'])

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
			}
			// ** WHY DIDN'T THE FOLLOWING WORK?? **
			//function(SessionService) {
			// 	return SessionService.getCurrentUser();
			// }
		]}
	})
	.otherwise({redirectTo: '/'});

}]);

// HTTP statuses used by Rest calls
var Status = new function() {
	this.Success = 200;

	this.Error = 500;
}