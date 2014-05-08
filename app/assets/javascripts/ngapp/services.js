angular.module('myApp.services', [])

.factory('SessionService', ['$http', '$q',
	function($http, $q) {
		
		var service = {
			
			currentUser: null,
			
			isAuthenticated: function() {
				return !!service.currentUser;
			},
			
			getCurrentUser: function(){
				if (service.isAuthenticated()) {
					return $q.when(service.currentUser);					
				}
				else {
					return $http.get('/api/v1/current_user').then(function(resp){
						return service.currentUser = resp.data;
					});
				}

			}
		
		};

		return service;
	}

])

.factory('UsersService', ['$http', '$q', function($http, $q){

	var service = {
		getUserInfo: function() {

		},

		updateUserInfo: function() {
			var defer = $q.defer();

			$http.post('/api/v1/users').then(function(data, status){
				if (data.status === 200)
					defer.resolve(data.data.user);
				else
					defer.reject(data);
			});

			return defer.promise;
		}
	};

	return service;

}]);