Template.feedbackQuiz.events
  'click .button-vote': (e) ->
    e.preventDefault()
    vote = new QuizVote(QuizVote.getValuesFromButtonEvent(e))
    vote.save (error, model) ->
      # TODO: Update template with voted values and show voting statuses in
      # template as well
      if error
        console.log("Couldn't vote, sorry.")
      else
        QuizVote.storeVoteInSession(vote)
        console.log("Voted, thanks!")

Template.feedbackQuiz.questions = [
  "More types of media besides text and images"
  "A more customizable layout or styling"
  "Making the navigation more obvious"
  "Offline exporting options"
  "Importing content from external platforms"
  "Maintaining and refining the current simplicity"
]
