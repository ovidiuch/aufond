class FilePicker extends ReactiveTemplate
  # Default options
  @options:
    mimetypes: ['image/*']
    services: [
      'COMPUTER'
      'DROPBOX'
      'EVERNOTE'
      'FACEBOOK'
      'FLICKR'
      'GOOGLE_DRIVE'
      'PICASA'
      'INSTAGRAM'
      'URL'
      'WEBCAM'
    ]

  template: Template.filePicker
  events:
    'click .btn': 'onSelect'
    'click .image': 'onRemove'

  createReactiveContainer: ->
    # Send "field" and "value" params to template data before creating the
    # reactive container and thus rendering the template for the first time
    params =
      field: @params.field
      value: @params.value
    @update(params, true, false)
    super()

  onSelect: (e) =>
    # Don't let the button act as a submit button if inside a form
    e.preventDefault()
    filepicker.pick(FilePicker.options, @onSuccess)

  onRemove: (e) =>
    e.preventDefault()
    @update(value: '', true)

  onSuccess: (FPFile) =>
    # Refresh template with the received url as the value
    @update(value: @getConvertedImageUrl(FPFile.url), true)

  getConvertedImageUrl: (imageUrl) ->
    return "#{imageUrl}/convert?w=100&h=100&fit=crop"


Meteor.startup ->
  # XXX enhance security if possible
  # https://developers.filepicker.io/docs/security/
  filepicker.setKey('AUSwIq7mUSuenbIA4BtCWz')
