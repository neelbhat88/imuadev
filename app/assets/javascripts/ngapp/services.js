angular.module('myApp.services', []);

angular.module('myApp.services')

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

])

.factory('OrganizationService', ['$http', '$q', function($http, $q) {

  var service = {
    all: function() {
      var defer = $q.defer();

      $http.get('/api/v1/organization')
        .then(function(resp, status){
          if (resp.data.success)
            defer.resolve(resp.data);
          else
            defer.reject(resp.data);
        });

      return defer.promise;
    },

    getOrganization: function(orgId) {
      var defer = $q.defer();

      $http.get('/api/v1/organization/' + orgId)
        .then(function(resp, status){
          if (resp.data.success)
            defer.resolve(resp.data);
          else
            defer.reject(resp.data);
        });

      return defer.promise;
    }
  };

  return service;

}])

.factory('LoadingService', [function() {
  var service = {
    laddaButton: null,

    buttonStart: function(elem) {
      service.laddaButton = Ladda.create(elem);
      service.laddaButton.start();
    },

    buttonStop: function() {
      service.laddaButton.stop();
    }
  }

  return service;
}])

.factory('UsersService', ['$http', '$q', function($http, $q){

  var service = {

    getUserInfo: function(userId) {

    },

    addUser: function(user) {
      var defer = $q.defer();

      $http.post('/api/v1/users', { user: user })
        .then(function(resp, status){
          if (resp.data.success)
            defer.resolve(resp.data);
          else
            defer.reject(resp.data);
        }
      );

      return defer.promise;
    },

    updateUserInfoWithPicture: function(user, formData) {
      var defer = $q.defer();

      formData.append("user[first_name]", user.first_name);
      formData.append("user[last_name]", user.last_name);
      formData.append("user[phone]", user.phone);

      $http.put('/api/v1/users/' + user.id, formData,
        {
          transformRequest: angular.identity,
          headers: {'Content-Type': undefined}
        })
        .then(function(resp, status){
          if (resp.data.success)
            defer.resolve(resp.data);
          else
            defer.reject(resp.data);
        });

      return defer.promise;
    },

    updateUserPassword: function(user, password) {
      var defer = $q.defer();

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
        });

      return defer.promise;
    },

    updateProfilePicture: function(user, formData) {
      var defer = $q.defer();

      $http.put('/api/v1/users/' + user.id, formData,
        {
          transformRequest: angular.identity,
          headers: {'Content-Type': undefined}
        })
        .then(function(resp, status){
          if (resp.data.success)
            defer.resolve(resp.data);
          else
            defer.reject(resp.data);
        }
      );

      return defer.promise;
    },

    newOrgAdmin: function(orgId)
    {
      return {
          email: "",
          first_name: "",
          last_name: "",
          role: 10,
          organization_id: orgId
      }
    }

  }

  return service;

}]);