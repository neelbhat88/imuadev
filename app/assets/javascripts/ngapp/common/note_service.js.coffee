angular.module('myApp')
.service 'NoteService', ['$http', ($http) ->
  today = new Date()
  dd = today.getDate()
  mm = today.getMonth()+1
  yyyy = today.getFullYear()

  if dd<10
    dd='0'+dd

  if mm<10
    mm='0'+mm

  today = mm+'/'+dd+'/'+yyyy;


  @newNote = (user) ->
    user_id: user.id,
    date: today,
    created_by: '',
    message: '',
    note_type: 0,
    time_spent: null,
    is_private: false


  @getUserNotes = (userId) ->
    $http.get "/api/v1/users/#{userId}/note"

  @saveUserNote = (userId, note) ->
    if note.id
      return $http.put "/api/v1/note/#{note.id}", {note: note}
    else
      return $http.post "api/v1/users/#{userId}/note", {note: note}

  @removeUserNote = (note) ->
    return $http.delete "/api/v1/note/#{note.id}"


  @
]
