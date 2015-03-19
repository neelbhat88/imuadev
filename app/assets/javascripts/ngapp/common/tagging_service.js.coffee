angular.module('myApp')
.service 'TaggingService', [() ->
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
  @
]
