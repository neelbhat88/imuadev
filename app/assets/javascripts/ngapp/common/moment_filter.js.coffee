angular.module('myApp')
.filter 'fromNow', () ->
  (date) ->
    moment(date).fromNow()

angular.module('myApp')
.filter 'formatMDY', () ->
  (date, format) ->
    if moment(date).isValid()
      moment(date).format('MM/DD/YYYY')
