angular.module('myApp')
.factory('RoadmapService', ['$http', '$q',
  function($http, $q){

    var service = {
      newRoadmap: function(orgId, name) {
        return {
          name: name,
          organization_id: orgId
        }
      },

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

      createRoadmap: function(orgId, name) {
        var roadmap = service.newRoadmap(orgId, name);

        var defer = $q.defer();

        $http.post('/api/v1/roadmap', {roadmap: roadmap})
          .then(function(resp, status){
            if (resp.data.success)
              defer.resolve(resp.data);
            else
              defer.reject(resp.data);
          });

        return defer.promise;
      },

      updateRoadmapName: function(roadmap, newname) {
        roadmap.name = newname;

        return $http.put('/api/v1/roadmap/' + roadmap.id, {roadmap: roadmap});
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
      },

      validateMilestone: function(timeUnit, milestone)
      {
        var errors = [];

        $.each(timeUnit.milestones, function(index, val) {
          if (this.id != milestone.id && (this.title == milestone.title || this.value == milestone.value))
          {
            errors.push("A milestone with the same title or value already exists in " + timeUnit.name);
            return false;
          }
        });

        return errors;
      }
    };

    return service;
  }
]);