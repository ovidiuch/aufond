class EntryCollection extends MeteorCollection
  toJSON: ->
    entries = super()
    for entry, i in entries
      entry.index = i + 1
    return entries


class Entry extends MeteorModel
  @collection: EntryCollection
  @mongoCollection: new Meteor.Collection 'entries'

  update: (data) ->
    if data.hasOwnProperty('date')
      data.time = @getTimeFromDate(data.date)
    super(data)

  validate: ->
    return "Headline can't be empty" unless @get('headline').length
    return "Invalid date" if isNaN(@getTimeFromDate(@get('date')))

  getTimeFromDate: (date) ->
    return Date.parse(date)
