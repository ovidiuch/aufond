class @EntryCollection extends MeteorCollection
  toJSON: (raw = false) ->
    entries = super(arguments...)
    unless raw
      for entry, i in entries
        entry.index = i + 1
    return entries


class @Entry extends MeteorModel
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
    profile = user.toJSON().profile
    profile.isHeader = true
    # Ensure a profile name by defaulting to the username
    profile.name = username if not profile.name
    items.push(profile)

    year = null
    for entry in user.getEntries({}, sort: {time: -1}).toJSON()
      # Mark first entry of an year in order to display the respective year
      # bubble above it
      if entry.year isnt year
        entry.firstInYear = true
        year = entry.year
      items.push(entry)
    return items

  update: (data) ->
    if data.hasOwnProperty('date')
      data.time = @getTimeFromDate(data.date)
    if data.hasOwnProperty('headline') and not data.hasOwnProperty('urlSlug')
      data.urlSlug = @createUrlSlug(data.headline)
    super(data)

  toJSON: (raw = false) ->
    data = super(arguments...)
    unless raw
      data.year = @getYear()
      data.hasExtendedContent = Boolean(data.content or data.images?.length)
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

  getUser: ->
    ###
      Proxy for fetching the User document of the Entry author
    ###
    return User.find(@get('createdBy'))

  addImage: (imageAttributes, callback) ->
    ###
      Attach a new image to an Entry
    ###
    images = @get('images')
    images.push(imageAttributes)
    @save(images: images, callback)

  getImage: (imageUrl) ->
    ###
      Fetch an image attached to an Entry, targeted by its url directly
    ###
    return _.find(@get('images'), (image) -> image.url is imageUrl)

  removeImage: (imageUrl, callback) ->
    ###
      Delete an image attached to an Entry, targeted by its url directly
    ###
    images = @get('images')
    images = _.reject(images, (image) -> image.url is imageUrl)
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
