Template.adminEntries.events
  'click .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.remove(data.id)

Template.adminEntries.entries = ->
  # Get own entries only
  filter =
    createdBy: Meteor.userId()
  return Entry.get(filter, sort: {time: -1}).toJSON()
