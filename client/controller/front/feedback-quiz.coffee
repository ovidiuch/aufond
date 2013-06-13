Template.feedbackQuiz.events
  'click .button-vote': (e) ->
    e.preventDefault()
    vote = new QuizVote(QuizVote.getValuesFromButtonEvent(e))
    vote.save (error, model) ->
      # XXX users aren't clearly notified if this fails
      QuizVote.storeVoteInSession(vote) unless error

Template.feedbackQuiz.questions = [
  "More types of media besides text and images"
  "A more customizable layout or styling"
  "Making the navigation more obvious"
  "Importing content from external platforms"
  "Offline exporting options"
  "Maintaining and refining the current simplicity"
]
