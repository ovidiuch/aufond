class @Campaign extends MeteorModel
  @collection: MeteorCollection
  @mongoCollection: new Meteor.Collection('campaigns')

  @publish: (name) ->
    if Meteor.isServer
      Meteor.publish name, ->
        # Only wire to the root user
        return [] unless User.find(@userId)?.isRoot()
        return Campaign.mongoCollection.find()

    if Meteor.isClient
      Meteor.subscribe(name)

  @allow: ->
    return unless Meteor.isServer
    @mongoCollection.allow
      # Only the root user can manage Campaign documents
      insert: (userId, doc) ->
        # Ensure author and timestamp of creation in every document
        doc.createdAt = Date.now()
        doc.createdBy = userId
        # This is a list of recipients that already received this Campaign
        doc.sentTo = []
        return User.find(userId)?.isRoot()
      update: (userId, doc, fields, modifier) ->
        return User.find(userId)?.isRoot()
      remove: (userId, doc) ->
        return User.find(userId)?.isRoot()

  toJSON: (raw = false) ->
    data = super(arguments...)
    unless raw
      data.sentToUserList = @getSentToUserList()
    return data

  validate: ->
    return "Subject can't be empty" unless @get('subject').length

  getSentToUserList: ->
    list = []
    for id in @get('sentTo')
      user = User.find(id)
      if user
        list.push(user.getEmailField())
      else
        list.push("Removed: id")
    return list.join(', ')

  getMessage: (userId) ->
    ###
      Decorate the campaign message with the unsubscribe link
    ###
    unsubscribeUrl = Meteor.absoluteUrl("unsubscribe/#{userId}")
    message = @get('message')
    message += "\n\n"
    message += "Follow this link to never hear from me again: #{unsubscribeUrl}"
    return message

Campaign.publish('campaigns')
Campaign.allow()
