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
    if data.hasOwnProperty('headline') and not data.hasOwnProperty('urlSlug')
      data.urlSlug = @createUrlSlug(data.headline)
    super(data)

  toJSON: ->
    data = super()
    data.year = @getYear()
    return data

  getPath: ->
    user = User.find(@get('createdBy'))
    return null unless user?
    return "#{user.get('username')}/#{@get('urlSlug')}"

  validate: ->
    return "Headline can't be empty" unless @get('headline').length
    return "Invalid date" if isNaN(@getTimeFromDate(@get('date')))

  save: ->
    # Make sure the entry has an array for the "images" field
    @set('images', []) unless @get('images')?
    super(arguments...)

  addImage: (imageAttributes, callback) ->
    # Start from an empty array if the images field is missing---should never
    # happen because of the "save" hook
    images = @get('images') or []
    images.push(imageAttributes)
    # A callback can be specified when adding an image to an entry, that will
    # end up being the save callback
    @save(images: images, callback)

  getYear: ->
    return new Date(@get('time')).getFullYear()

  getTimeFromDate: (date) ->
    return Date.parse(date)

  createUrlSlug: (headline) ->
    # TODO replace accents
    return headline.toLowerCase()
                   # Remove anything that's not a a-z0-9_ word, a hypen or a
                   # white space
                   .replace(/[^a-z0-9 -]+/ig, '')
                   # Replace all white spaces with hypens, while making sure
                   # there will never be more than one consecutive hypen
                   .replace(/\ /g, '-').replace(/-+/g, '-')

Entry.publish('entries')
Entry.allow()
