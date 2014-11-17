angular.module('myApp')
.directive 'comments', ['CommentService', (CommentService) ->
  restrict: 'E',
  link: (scope, elem, attrs) ->
    scope.comments = []
    scope.editing_new_comment = false
    scope.new_comment = ""

    CommentService.getComments(scope.commentable_object.type, scope.commentable_object.id)
      .then (org) ->
        scope.comments = CommentService.parseComments(org)
        scope.loaded_comments = true

    scope.addNewComment = () ->
      scope.editing_new_comment = true
      scope.new_comment = ""

    scope.cancelAddNewComment = () ->
      scope.editing_new_comment = false

    scope.saveNewComment = () ->
      CommentService.saveNewComment(scope.commentable_object.type, scope.commentable_object.id, scope.new_comment)
        .then (saved_comment) ->
          saved_comment.user = scope.current_user
          scope.comments.push(saved_comment)
          scope.editing_new_comment = false

  templateUrl: 'common/comment_list.html'
]
