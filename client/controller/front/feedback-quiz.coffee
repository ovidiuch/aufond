getValuesFromVote = (e) ->
  $button = $(e.currentTarget)
  return {
    question: $button.closest('li').find('.question').text()
    vote: parseInt($button.data('vote'), 10)
  }

Template.feedbackQuiz.events
  'click .button-vote': (e) ->
    e.preventDefault()
    vote = new QuizVote(getValuesFromVote(e))
    vote.save (error, model) ->
      # Store vote in session and update template, account for errors
      console.log(arguments...)

Template.feedbackQuiz.questions = [
  "More types of media besides text and images"
  "A more customizable layout or styling"
  "Making the navigation more obvious"
  "Offline exporting options"
  "Importing content from external platforms"
  "Maintaining and refining the current simplicity"
]
