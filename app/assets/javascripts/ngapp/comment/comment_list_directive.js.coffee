angular.module('myApp')
.directive 'comments', ['CommentService', (CommentService) ->
  restrict: 'E',
  scope: {
    commentableObjectRoute: '@',
    commentableObjectId: '='
  }

  link: (scope, elem, attrs) ->
    scope.comments = []
    scope.new_comment = {}
    scope.new_comment.text = ""
    scope.new_comment.editing = false

    CommentService.getComments(scope.commentableObjectRoute, scope.commentableObjectId)
      .then (org) ->
        scope.comments = CommentService.parseComments(org)
        scope.loaded_comments = true

    scope.addNewComment = () ->
      scope.new_comment.editing = true
      scope.new_comment.text = ""

    scope.cancelAddNewComment = () ->
      scope.new_comment.editing = false

    scope.saveNewComment = () ->
      CommentService.saveNewComment(scope.commentableObjectRoute, scope.commentableObjectId, scope.new_comment.text)
        .then (org) ->
          scope.comments = CommentService.parseComments(org)
          scope.new_comment.editing = false

  templateUrl: 'common/comment_list.html'
]
