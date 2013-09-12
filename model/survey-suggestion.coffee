class @SurveySuggestion extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: new Meteor.Collection 'surveySuggestions'

  @getSuggestionDateFromCookie: ->
    suggestionDate = $.cookie('surveySuggestionDate')
    return suggestionDate or 0

  @storeSuggestionDateInCookie: ->
    $.cookie('surveySuggestionDate', Date.now(), expires: 365)

  @publish: ->
    # Don't publish survey suggestions at all, they are write-only

  @allow: ->
    return unless Meteor.isServer

    @mongoCollection.allow
      insert: (userId, doc) ->
        # Ensure author and timestamp of creation in every document
        doc.createdAt = Date.now()
        doc.createdBy = userId
        # Allow anybody to post survey suggestions questions
        # XXX is there anything to do here to prevent spammers?
        # Check out https://github.com/tmeasday/meteor-accounts-anonymous
        return true
      update: (userId, doc, fields, modifier) ->
        # For now survey suggestions should remain unaltered
        return false
      remove: (userId, doc) =>
        # For now survey suggestions should remain unaltered
        return false

  validate: ->
    return "Sorry? Couldn't hear that" unless @get('message').length
    # Prevent from sending another suggestion in less than a minute
    previousSuggestionDate = @constructor.getSuggestionDateFromCookie()
    if Date.now() - previousSuggestionDate < 60 * 1000
      return "Already a new suggestion? You should just call me: " +
             "__+40 726 189 126__"

  save: ->
    # Attach the creating time and user info for betters stats
    @update
      createdByGuestId: User.getGuestId()
      createdByUserAgent: navigator?.userAgent
    super(arguments...)

  saveCallback: ->
    callback = super(arguments...)
    return (error, id) =>
      # Store the date in the cookie whenever a user posts a suggestion, in
      # order to prevent too many consecutive posts
      @constructor.storeSuggestionDateInCookie() unless error
      callback(arguments...)


SurveySuggestion.publish('surveySuggestions')
SurveySuggestion.allow()
