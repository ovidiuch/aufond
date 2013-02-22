class Entry extends MeteorModel
  @collection: new Meteor.Collection 'entries'

  validate: ->
    return "Headline can't be empty" unless @get('headline').length
    return "Invalid date" if isNaN(@getTimeFromDate(@get('date')))

  getTimeFromDate: (date) ->
    return Date.parse(date)
