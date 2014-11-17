angular.module('myApp')
.service 'CommentService', ['$http', '$q', ($http, $q) ->
  self = this

  @parseComments = (org) ->
    org.comments = _.flatten(_.pluck(org.users, "comments"), true)
    _.each(org.comments, (c) -> c.user = _.find(org.users, (u) -> c.user_id == u.id))
    return org.comments

  @doSaveNewComment = (commentable_object_type, commentable_object_id, comment) ->
    $http.post "api/v1/#{commentable_object_type}/#{commentable_object_id}/comment",
      { comment: comment }

  @doGetComments = (commentable_object_type, commentable_object_id) ->
    $http.get "api/v1/#{commentable_object_type}/#{commentable_object_id}/comments"

  @saveNewComment = (commentable_object_type, commentable_object_id, comment) ->
    defer = $q.defer()
    @doSaveNewComment(commentable_object_type, commentable_object_id, comment)
      .success (data) ->
        defer.resolve(data.comment)
    defer.promise

  @getComments = (commentable_object_type, commentable_object_id) ->
    defer = $q.defer()
    @doGetComments(commentable_object_type, commentable_object_id)
      .success (data) ->
        defer.resolve(data.organization)
    defer.promise

  @

]
