angular.module('myApp')
.service 'CommentService', ['$http', '$q', ($http, $q) ->
  self = this

  @saveNewComment = (commentable_object, comment) ->
    $http.post "api/v1/user_assignment/#{commentable_object.id}/comment",
      { comment: comment }

  @

]
