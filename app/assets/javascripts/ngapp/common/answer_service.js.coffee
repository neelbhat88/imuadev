angular.module('myApp')
.service "AnswerService", ['$http', ($http) ->

  @all = ()->
    $http.get ('/api/v1/answers')

  @
]
