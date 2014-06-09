angular.module('myApp')
.factory('UsersService', ['$http', '$q', function($http, $q){

  var service = {

    getUserInfo: function(userId) {

    },

    addUser: function(user) {
      return $http.post('/api/v1/users', { user: user });
    },

    updateUserInfoWithPicture: function(user, formData) {
      formData.append("user[first_name]", user.first_name);
      formData.append("user[last_name]", user.last_name);
      formData.append("user[phone]", user.phone);

      return $http.put('/api/v1/users/' + user.id, formData,
        {
          transformRequest: angular.identity,
          headers: {'Content-Type': undefined}
        });
    },

    updateUserPassword: function(user, password) {
      var user = {
        id: user.id,
        current_password: password.current,
        password: password.new,
        password_confirmation: password.confirm
      };

      return $http.put('/api/v1/users/' + user.id + '/update_password', {user: user});
    },

    updateProfilePicture: function(user, formData) {
      return $http.put('/api/v1/users/' + user.id, formData,
        {
          transformRequest: angular.identity,
          headers: {'Content-Type': undefined}
        });
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