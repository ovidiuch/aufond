class EntryCollection extends MeteorCollection
  toJSON: ->
    entries = super()
    for entry, i in entries
      entry.index = i + 1
    return entries


class Entry extends MeteorModel
  @collection: EntryCollection
  @mongoCollection: new Meteor.Collection 'entries'

  @getByYears: (username) ->
    ###
      Create list with year separators and entry items aggregated into a single
      collection. The items share a common _type_ key ("post" or "year")
    ###
    items = []

    # Only select entries for a specific username
    user = User.find(username: username)
    return items unless user

    # Add user data as the first item of list
    profile = user.get('profile')
    items.push
      type: 'header'
      name: profile.name
      title: profile.title
      avatar: profile.avatar

    year = null
    for entry in @get({createdBy: user.get('_id')}, sort: {time: -1}).toJSON()
      # Push the year entry before the first entry from that year
      if entry.year isnt year
        year = entry.year
        items.push
          type: 'year'
          year: year
      # Add the type key to the entry data
      items.push _.extend {type: 'post'}, entry
    return items

  update: (data) ->
    if data.hasOwnProperty('date')
      data.time = @getTimeFromDate(data.date)
    super(data)

  toJSON: ->
    data = super()
    data.year = @getYear()
    return data

  validate: ->
    return "Headline can't be empty" unless @get('headline').length
    return "Invalid date" if isNaN(@getTimeFromDate(@get('date')))

  getYear: ->
    return new Date(@get('time')).getFullYear()

  getTimeFromDate: (date) ->
    return Date.parse(date)


Entry.publish('entries')
Entry.allow()
