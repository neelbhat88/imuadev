angular.module('myApp')
.filter 'underscoresToSpaces', () ->
  (str) ->
    str.replace /_/g, ' '
