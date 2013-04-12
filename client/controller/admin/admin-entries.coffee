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

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.remove(data.id)

  'click .btn-image-attach': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    filepicker.pick FilePicker.options, (FPFile) ->
      Entry.find(id)?.addImage
        url: FPFile.url
        caption: FPFile.filename

  'click .btn-image-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postImageModal.update(data)

  'click .btn-image-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.find(data.id)?.removeImage(data.image)

Template.adminEntries.entries = ->
  # Get own entries only
  filter =
    createdBy: Meteor.userId()
  return Entry.get(filter, sort: {time: -1}).toJSON()
