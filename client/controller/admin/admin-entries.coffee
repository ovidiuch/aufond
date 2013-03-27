Template.adminEntries.events
  'click .btn-view': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    entry = Entry.find(id)
    if entry
      App.router.navigate(entry.getPath(), trigger: true)

  'click .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

  'click .btn-attach-image': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    filepicker.pick(FilePicker.options, (FPFile) ->
      # TODO create image and attach to post id
      console.log(FPFile.url)
    )

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
