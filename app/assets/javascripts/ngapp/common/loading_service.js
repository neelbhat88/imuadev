angular.module('myApp')
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
}]);