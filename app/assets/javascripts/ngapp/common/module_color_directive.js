angular.module('myApp')
.directive('modulecolor', ['CONSTANTS', function(CONSTANTS) {
  return {
    link: function(scope, element, attrs) {
      attrs.$observe('modulecolor', function(value){
        var module = value;
        var colorClass = "";
        var colorArray = ["color--academics", "color--service"]

        switch(module){
        case CONSTANTS.MODULES.academics:
          colorClass = "color--academics";
          break;
        case CONSTANTS.MODULES.service:
          colorClass = "color--service";
          break;
        }

        $(element).removeClass(colorArray.join(" "));
        $(element).addClass(colorClass);
      });
    }
  }
}]);