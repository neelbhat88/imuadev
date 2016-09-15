angular.module('myApp')
.controller 'SuperAdminCarolineCtrl', ['$scope', '$routeParams'
  ($scope, $routeParams) ->
    $scope.currentFilter = null
    $scope.user = $scope.current_user
    $scope.routeParams = $routeParams.num

    setCurrentFilter = (type) ->
      $scope.currentFilter = type
      return

    $scope.setCurrentFilter = setCurrentFilter

    $scope.types = [
      {"id": 0, "name": "question"},
      {"id": 1, "name": "answer"}
    ]

    $scope.dataset = [
      {"id": 1, "type": "question", "text": "1q. What one thing are you hoping to get most out of this project?"},

      {"id": 1, "type": "answer", "text": "1a. I hope to become more experienced with developing a project as a team
    as well as learn some practical skills with Ruby, Rails, AngularJS, etc.
    outside of a strictly-learning environment."},

      {"id": 2, "type": "question", "text": "2q. What is one of your current skills/strengths (doesn't have to be a
      technical skill) you are hoping to further strengthen through this project?"},

      {"id": 2, "type": "answer", "text": "2a. I'm looking forward to strengthening my front end developing
      skills as well as jumping into more of the back end world."},

      {"id": 3, "type": "question", "text": "3q. What are one or two things you are excited to learn about?"},

      {"id": 3, "type": "answer", "text": "3a. I'm excited to learn more about Imua (the project and the source code)
      and the ways in which I can give back."},

      {"id": 4, "type": "question", "text": "4q. What are one or two things, if any, you know already that you don't want
    to do or work on?"},

      {"id": 4, "type": "answer", "text": "4a. I'd love to work on everything that I've heard about so far! I'm
  pretty eager when it comes to trying new things especially in development."},

      {"id": 5, "type": "question", "text": "5q. What book are you currently reading? Or what was the last good book you read?"},

      {"id": 5, "type": "answer", "text": "5a. I'm currently finishing up 'GO TO' by Steve Lohr. It's a concise overview of
      the programmers who created the software revolution. I just finished Nobel Prize in Physics winner Richard Feynman's
      autobiography, 'Surely You're Joking Mr. Feynman!'. It's a great and easy read filled with fascinating experiments
      and hilarious adventures. (I will admit that both of those books are on my pre-college reading list for CS students,
      for leisure I've just started 'War and Peace' and I'm enjoying that a lot)"},

      {"id": 6, "type": "question", "text": "6q. What are your hobbies?"},

      {"id": 6, "type": "answer", "text": "6a. I love reading and spend most of my 'free' time doing that.
      I've been playing piano since I was 6 and violin since I was 13, I do yoga, spend time
      playing and relaxing with our cat and kittens, and sometimes find time to
      sew for my and my sister's Etsy shop that fundraises for our friend's children's
      home in Rwanda."},

      {"id": 7, "type": "question", "text": "7q. What is your ideal Saturday look like? Or said another way,
      when you actually have a Saturday where there is nothing planned, how do
        you like to spend the day?"},

      {"id": 7, "type": "answer", "text": "7a. My ideal Saturday is sleeping in to at least 8, going to the Farmer's
          Market, possibly grabbing a crepe from the famous crepe truck here in
          downtown Bentonville, and spending the rest of the day relaxing and reading."},

      {"id": 8, "type": "question", "text": "8q. If you were in a room of 100 random people and have to pick one thing
    that you are better than every other person at, what would that one thing be?"},

      {"id": 8, "type": "answer", "text": "8a. I'd probably be better than everyone at Apples to Apples or speed
  scrabble. Also, I doubt someone else would be able to play Presto from
  Vivaldi's Concerto for Violin in A minor on the spot :)"} ]

]
