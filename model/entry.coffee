class Entry extends Backbone.Model
  @collection: new Meteor.Collection 'entries'

  # XXX move this in a Meteor Model class
  sync: (method, model, options) ->
    switch method
      when 'create'
        data = model.toJSON()
        @constructor.collection.insert data, (error, id) ->
          if error
            options.error(model, error.reason)
          else
            options.success(id)

  validate: (attrs, options) ->
    return "Headline can't be empty" unless attrs.headline.length
    return "Invalid date" if isNaN(@getTimeFromDate(attrs.date))

  getTimeFromDate: (date) ->
    return Date.parse(date)
