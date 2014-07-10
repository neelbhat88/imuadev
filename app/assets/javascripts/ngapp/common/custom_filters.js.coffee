angular.module('myApp')
.filter 'underscoresToSpaces', () ->
  (str) ->
    if typeof str != "string"
      return str
    str.replace /_/g, ' '
