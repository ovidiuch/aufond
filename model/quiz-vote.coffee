class @QuizVote extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: new Meteor.Collection 'quizVotes'

  @getValuesFromButtonEvent: (e) ->
    $button = $(e.currentTarget)
    # Return
    question: $button.closest('li').find('.question').text()
    vote: parseInt($button.data('vote'), 10)

  @getVotesFromSession: ->
    return Session.get('votedQuizQuestions') or {}

  @storeVoteInSession: (vote) ->
    votes = @getVotesFromSession()
    votes[vote.get('question')] = vote.get('vote')
    Session.set('votedQuizQuestions', votes)

  @publish: ->
    # Don't publish quiz votes at all, they are write-only

  @allow: ->
    return unless Meteor.isServer

    @mongoCollection.allow
      insert: (userId, doc) ->
        # Allow anybody to vote on quiz questions
        # XXX is there anything to do here to prevent spammers?
        # Check out https://github.com/tmeasday/meteor-accounts-anonymous
        return true
      update: (userId, doc, fields, modifier) ->
        # For now quiz votes should remain unaltered
        return false
      remove: (userId, doc) =>
        # For now quiz votes should remain unaltered
        return false

  save: ->
    # Attach the creating time and the user browser agent for better stats
    @update
      createdAt: Date.now()
      userAgent: navigator?.userAgent
    super(arguments...)


QuizVote.publish('quizVotes')
QuizVote.allow()
