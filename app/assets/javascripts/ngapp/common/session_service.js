angular.module('myApp')
.factory('SessionService', ['$http', '$q',
  function($http, $q) {

    var service = {

      currentUser: null,

      isAuthenticated: function() {
        return !!service.currentUser;
      },

      isAuthorized: function(authorizedRoles) {
        if (!angular.isArray(authorizedRoles))
          authorizedRoles = [authorizedRoles];

        return ( service.isAuthenticated() &&
               authorizedRoles.indexOf(service.currentUser.role) !== -1 )
      },

      getCurrentUser: function(){
        if (service.isAuthenticated()) {
          return $q.when(service.currentUser);
        }
        else {
          return $http.get('/api/v1/current_user').then(function(resp){
            service.currentUser = resp.data.user;

            return service.currentUser;
          });
        }

      },

      isSuperAdmin: function() {
        return !!(service.currentUser && service.currentUser.is_super_admin)
      }

    };

    return service;
  }

]);