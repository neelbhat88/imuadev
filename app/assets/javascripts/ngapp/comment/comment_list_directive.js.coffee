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
    scope.new_comment = {}

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
      if !comment
        CommentService.saveNewComment(scope.commentableObjectRoute, scope.commentableObjectId, scope.new_comment.comment)
          .then (org) ->
            scope.comments = CommentService.parseComments(org)
            scope.new_comment.comment = ""
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
            # ToDo: Think about putting all of this in a comment_controller that is instantianted
            # in the comment_list.html with a ng-controller if possible.
            # This will allow us to access parent scope stuff like addSuccessMessage.
            # Currently because of the isolate scope we can't. I think the main difficulty will be
            # figuring out how to pass in the commentableObjectRoute and ID into the controller.
            #scope.addSuccessMessage("Comment deleted")


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
