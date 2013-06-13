class @QuizVote extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: new Meteor.Collection 'quizVotes'

  @getValuesFromButtonEvent: (e) ->
    $button = $(e.currentTarget)
    # Return
    question: $button.closest('li').find('.question').text()
    # jQuery automatically converts "true/false" strings into Boolean
    vote: $button.data('vote')

  @getVotesFromSession: ->
    return Session.get('quizVotes') or {}

  @storeVoteInSession: (vote) ->
    votes = @getVotesFromSession()
    votes[vote.get('question')] = vote.get('vote')
    Session.set('quizVotes', votes)

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
    # Attach the creating time and user info for betters stats
    @update
      createdAt: Date.now()
      # Most users will not be logged in when they vote, but if some do it
      # would be very interesting to put a face to their votes
      createdBy: Meteor.userId()
      createdByUserAgent: navigator?.userAgent
    super(arguments...)


QuizVote.publish('quizVotes')
QuizVote.allow()
