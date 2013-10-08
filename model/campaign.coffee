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
    return "Subject can't be empty" if _.isEmpty(@get('subject'))

  getSentToUserList: ->
    list = []
    return list unless @get('sentTo')
    for id in @get('sentTo')
      user = User.find(id)
      if user
        list.push(user.getEmailField())
      else
        list.push("Removed: id")
    return list.join(', ')

  getMessage: (user) ->
    ###
      Decorate the campaign message with user fields and the unsubscribe link
    ###
    unsubscribeUrl = Meteor.absoluteUrl("unsubscribe/#{user.get('_id')}")
    message = @get('message')
    message = message.replace('{{username}}', user.get('username'))
    # Default to the username when no full name is provided
    if user.get('profile').name
      # Get only the first name
      name = user.getCleanName().split(' ')[0]
    else
      name = user.get('username')
    message = message.replace('{{name}}', name)
    message += "\n\n---\n\n"
    message += "Follow this link to never hear from me again: #{unsubscribeUrl}"
    return message

Campaign.publish('campaigns')
Campaign.allow()
