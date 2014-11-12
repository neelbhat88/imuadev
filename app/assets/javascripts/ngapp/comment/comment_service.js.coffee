angular.module('myApp')
.service 'CommentService', ['$http', '$q', ($http, $q) ->
  self = this

  @doSaveNewComment = (commentable_object_type, commentable_object_id, comment) ->
    $http.post "api/v1/#{commentable_object_type}/#{commentable_object_id}/comment",
      { comment: comment }

  @saveNewComment = (commentable_object_type, commentable_object_id, comment) ->
    defer = $q.defer()
    @doSaveNewComment(commentable_object_type, commentable_object_id, comment)
      .success (data) ->
        defer.resolve(data.comment)
    defer.promise

  @

]
