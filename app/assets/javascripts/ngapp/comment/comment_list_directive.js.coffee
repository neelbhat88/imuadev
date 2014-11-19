angular.module('myApp')
.directive 'comments', ['CommentService', (CommentService) ->
  restrict: 'E',
  scope: {
    currentUser: '='
    commentableObjectRoute: '@',
    commentableObjectId: '='
  }

  link: (scope, elem, attrs) ->
    scope.comments = []

    CommentService.getComments(scope.commentableObjectRoute, scope.commentableObjectId)
      .then (org) ->
        scope.comments = CommentService.parseComments(org)
        scope.loaded_comments = true

    scope.addNewComment = () ->
      _.each(scope.comments, (c) -> scope.cancelEditComment(c))
      new_comment = CommentService.newComment()
      new_comment.editing = true
      scope.comments.push(new_comment)

    scope.editComment = (comment) ->
      _.each(scope.comments, (c) -> scope.cancelEditComment(c))
      comment.new_comment = comment.comment
      comment.editing = true

    scope.saveComment = (comment) ->
      if comment.id == null
        CommentService.saveNewComment(scope.commentableObjectRoute, scope.commentableObjectId, comment.new_comment)
          .then (org) ->
            scope.comments = CommentService.parseComments(org)
      else
        CommentService.saveComment(comment.id, comment.new_comment)
          .then (org) ->
            scope.comments = CommentService.parseComments(org)

    scope.cancelEditComment = (comment) ->
      if comment.id == null
        scope.comments = _.without(scope.comments, comment)
      else
        comment.editing = false

    scope.deleteComment = (comment) ->
      _.each(scope.comments, (c) -> scope.cancelEditComment(c))
      if window.confirm "Are you sure you want to delete this comment?"
        CommentService.deleteComment(comment.id)
          .then (org) ->
            scope.comments = CommentService.parseComments(org)


    scope.canEditComment = (comment) ->
      return comment.user_id == scope.currentUser.id

    scope.canDeleteComment = (comment) ->
      return comment.user_id == scope.currentUser.id

    scope.editingNewComment = () ->
      last_comment = _.last(scope.comments)
      return last_comment && last_comment.id == null

    scope.isNewComment = (comment) ->
      return comment.id == null


  templateUrl: 'common/comment_list.html'
]
