angular.module('myApp.services', []);

angular.module('myApp.services').factory('SessionService', ['$http', '$q',
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
		getUserInfo: function(userId) {

		},

		updateUserInfo: function(user) {
			var defer = $q.defer();

			$http.put('/api/v1/users/' + user.id, {user: user})
				.then(function(resp, status){
					if (resp.data.success)
						defer.resolve(resp.data);
					else
						defer.reject(resp.data);
				}	
			);

			return defer.promise;
		},

		updateUserPassword: function(user, password) {
			var defer = $q.defer();
			
			if (!password.current || !password.new || !password.confirm)
				return;

			var user = {
				id: user.id,
				current_password: password.current,
				password: password.new,
				password_confirmation: password.confirm
			};

			$http.put('/api/v1/users/' + user.id + '/update_password', {user: user})
				.then(function(resp, status){
					if (resp.data.success)
						defer.resolve(resp.data);
					else
						defer.reject(resp.data);
				}			
			);

			return defer.promise;
		}
	};

	return service;

}]);