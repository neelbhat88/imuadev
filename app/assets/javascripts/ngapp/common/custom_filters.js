angular.module('myApp')
.filter('underscoresToSpaces', function() {
    return function(str) {
      if( typeof(str) !== "string" )
        return "";
      return str.replace(/_/g, ' ');
    };
});
