angular.module('myApp')
.filter 'fromNow', () ->
  (date) ->
    moment(date).fromNow()
