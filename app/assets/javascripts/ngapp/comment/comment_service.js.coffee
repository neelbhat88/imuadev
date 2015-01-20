angular.module('myApp')
.service 'CommentService', ['$http', '$q', ($http, $q) ->
  self = this

  @newComment = () ->
    id: null,
    comment: "",
    new_comment: ""

  @parseComments = (org) ->
    org.comments = _.flatten(_.pluck(org.users, "comments"), true)
    _.each(org.comments, (c) -> c.user = _.find(org.users, (u) -> c.user_id == u.id))
    return org.comments


  @doSaveNewComment = (commentable_object_type, commentable_object_id, comment) ->
    $http.post "api/v1/#{commentable_object_type}/#{commentable_object_id}/comment",
      { comment: comment }

  @doSaveComment = (comment_id, comment) ->
    $http.put "api/v1/comment/#{comment_id}",
      { comment: comment }

  @doGetComments = (commentable_object_type, commentable_object_id) ->
    $http.get "api/v1/#{commentable_object_type}/#{commentable_object_id}/comments"

  @doDeleteComment = (comment_id) ->
    $http.delete "api/v1/comment/#{comment_id}"


  @saveNewComment = (commentable_object_type, commentable_object_id, comment) ->
    defer = $q.defer()
    @doSaveNewComment(commentable_object_type, commentable_object_id, comment)
      .success (data) ->
        defer.resolve(data.organization)
    defer.promise

  @saveComment = (comment_id, comment) ->
    defer = $q.defer()
    @doSaveComment(comment_id, comment)
      .success (data) ->
        defer.resolve(data.organization)
    defer.promise

  @getComments = (commentable_object_type, commentable_object_id) ->
    defer = $q.defer()
    @doGetComments(commentable_object_type, commentable_object_id)
      .success (data) ->
        defer.resolve(data.organization)
    defer.promise

  @deleteComment = (comment_id) ->
    defer = $q.defer()
    @doDeleteComment(comment_id)
      .success (data) ->
        defer.resolve(data.organization)
    defer.promise


  @

]
