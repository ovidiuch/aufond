Template.adminEntries.events
  'mouseup .button-view': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    entry = Entry.find(id)
    if entry
      App.router.navigate(entry.getPath(), trigger: true)

  'mouseup .button-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

  'mouseup .button-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.remove(data.id)

  'mouseup .button-image-attach': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    filepicker.pick FilePicker.options, (FPFile) ->
      Entry.find(id)?.addImage
        url: FPFile.url
        caption: FPFile.filename

  'mouseup .button-image-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postImageModal.update(data)

  'mouseup .button-image-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.find(data.id)?.removeImage(data.image)

Template.adminEntries.entries = ->
  # Get own entries only
  filter =
    createdBy: Meteor.userId()
  return Entry.get(filter, sort: {time: -1}).toJSON()
