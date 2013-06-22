Template.adminEntries.events
  'click .button-view': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    entry = Entry.find(id)
    if entry
      App.router.navigate(entry.getPath(), trigger: true)

  'click .button-edit': (e) ->
    e.preventDefault()
    App.postModal.update($(e.currentTarget).data())

  'click .button-delete': (e) ->
    e.preventDefault()
    App.deletePostModal.update($(e.currentTarget).data())

  'click .button-image-attach': (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    filepicker.pick FilePicker.options, (FPFile) ->
      Entry.find(id)?.addImage
        url: FPFile.url
        caption: FPFile.filename

  'click .button-image-edit': (e) ->
    e.preventDefault()
    App.postImageModal.update($(e.currentTarget).data())

  'click .button-image-delete': (e) ->
    e.preventDefault()
    App.deletePostImageModal.update($(e.currentTarget).data())

Template.adminEntries.entries = ->
  # Get own entries only
  filter =
    createdBy: Meteor.userId()
  return Entry.get(filter, sort: {time: -1}).toJSON()
