angular.module("myApp")
.service("UserClassService", ['$http', function($http){
  var self = this;

  self.all = function(user) {
    return $http.get('/api/v1/users/' + user.id + '/time_unit/' + user.time_unit_id + '/classes');
  }

  self.new = function(user) {
    return {
      name: "",
      grade: "",
      time_unit_id: user.time_unit_id,
      user_id: user.id,
      editing: true
    }
  }

  self.save = function(user_class) {
    if (user_class.id)
      return $http.put('/api/v1/users/'+ user_class.user_id + '/classes/' + user_class.id, {user_class: user_class});
    else
      return $http.post('/api/v1/users/' + user_class.user_id + '/classes', {user_class: user_class});
  }

  self.getGPA = function(user_classes)
  {
    var totalGPA = 0;

    if (user_classes.length == 0)
      return 0;

    $.each(user_classes, function(index, val) {
       totalGPA += this.gpa;
    });

    return (totalGPA / user_classes.length).toFixed(2);
  }
}]);


// Error
// Delete
// Lots of classes side bar