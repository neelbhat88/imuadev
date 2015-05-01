angular.module('myApp')
.service 'TaggingService', ['$http', ($http) ->
  @parseTagsForUsers = (users, tags, taggings) ->
    for user in users
      user.tag_list = []
      userTaggings = _.where(taggings, {taggable_id: user.id})
      userTags = []
      for tagging in userTaggings
        for tag in tags
          if tag.id == tagging.tag_id
            userTags.push(tag.name)
      user.tag_list = userTags
    users

  @getUserTags = (userId) ->
    $http.get "/api/v1/users/#{userId}/user_tag"

  @getOrgTags = (orgId) ->
    return $http.get "/api/v1/organization/#{orgId}/tag"

  @saveTagMultipleUsers = (orgId, users, tag) ->
    return $http.post "/api/v1/tag/#{orgId}/multiple", {users: users, tag: tag}

  @saveTagSingleUser = (userId, tag) ->
    return $http.post "/api/v1/users/#{userId}/user_tag", {tag: tag}

  @removeTagSingleUser = (userId, tag) ->
    return $http.delete "/api/v1/user_tag/#{userId}?tag=#{tag}"


  @
]
