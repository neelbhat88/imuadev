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

.factory('RoadmapService', ['$http', '$q',
  function($http, $q){

    var service = {
      getRoadmap: function(orgId) {
        var defer = $q.defer();

        $http.get('/api/v1/organization/' + orgId + '/roadmap')
          .then(function(resp, status){
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      getEnabledModules: function(orgId) {
        var defer = $q.defer();

        $http.get('api/v1/organization/' + orgId + '/modules')
          .then(function(resp, status){
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      addTimeUnit: function(orgId, rId, tu_obj){
        var defer = $q.defer();

        var time_unit = {
          organization_id: orgId,
          roadmap_id: rId,
          name: tu_obj.name
        };

        $http.post('/api/v1/time_unit', { time_unit: time_unit } )
          .then(function(resp, status) {
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      updateTimeUnit: function(time_unit) {
        var defer = $q.defer();

        $http.put('/api/v1/time_unit/' + time_unit.id, { time_unit: time_unit } )
          .then(function(resp, status) {
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      deleteTimeUnit: function(time_unit_id) {
        var defer = $q.defer();

        $http.delete('/api/v1/time_unit/' + time_unit_id)
          .then(function(resp, status) {
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      addMilestone: function(milestone) {
        var defer = $q.defer();

        $http.post('/api/v1/milestone', {milestone: milestone})
          .then(function(resp, status) {
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      updateMilestone: function(milestone) {
        var defer = $q.defer();

        $http.put('/api/v1/milestone/' + milestone.id, { milestone: milestone })
          .then(function(resp, status) {
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      deleteMilestone: function(milestoneId) {
        var defer = $q.defer();

        $http.delete('/api/v1/milestone/' + milestoneId)
          .then(function(resp, status) {
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
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
    }
  };

  return service;

}])

.factory('UsersService', ['$http', '$q', function($http, $q){

  var service = {

    getUserInfo: function(userId) {

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
    }

  }

  return service;

}]);