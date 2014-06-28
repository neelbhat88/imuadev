angular.module('myApp')
.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/progress',
    templateUrl: 'progress/progress.html',
    controller: 'ProgressController',
    resolve:
      current_user: ['SessionService', (SessionService) ->
        SessionService.getCurrentUser()
      ]
]