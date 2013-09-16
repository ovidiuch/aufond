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

  validate: ->
    return "Subject can't be empty" unless @get('subject').length


Campaign.publish('campaigns')
Campaign.allow()
