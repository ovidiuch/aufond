class @AdminEntries extends AdminTab
  template: Template.adminEntries

  constructor: ->
    # Extend AdminTab events to accomodate actions for the entry images
    events =
      'click .button-image-attach': 'onImageAttach'
      'click .button-image-edit': 'onImageEdit'
      'click .button-image-delete': 'onImageDelete'
    @events = _.extend(events, @events)
    super(arguments...)

  onView: (e) =>
    e.preventDefault()
    entry = Entry.find($(e.currentTarget).data('id'))
    App.router.navigate(entry.getPath(), trigger: true)

  onImageAttach: (e) =>
    e.preventDefault()
    entry = Entry.find($(e.currentTarget).data('id'))
    filepicker.pick FilePicker.options, (FPFile) ->
      entry.addImage(url: FPFile.url, caption: FPFile.filename)

  onImageEdit: (e) =>
    e.preventDefault()
    App.postImageModal.update($(e.currentTarget).data())

  onImageDelete: (e) =>
    e.preventDefault()
    App.deletePostImageModal.update($(e.currentTarget).data())

  getCollectionItems: ->
    return User.current()?.getEntries({}, {sort: {time: -1}}).toJSON()
