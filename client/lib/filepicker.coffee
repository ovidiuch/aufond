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

  @getResizedImageUrl: (url, width = 100, height = 100, fit = 'crop') ->
    return "#{url}/convert?w=#{width}&h=#{height}&fit=#{fit}"

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
    @update(value: FPFile.url, true)


Handlebars.registerHelper 'getResizedImageUrl', (url, width, height, fit) ->
  # Important: all arguments must be specified (we can't rely on defaults
  # because Handlebars helpers have an extra "options" argument at the end of
  # the argument list which would take the place of the first unspecified
  # argument)
  return FilePicker.getResizedImageUrl(arguments...)


Meteor.startup ->
  # XXX enhance security if possible
  # https://developers.filepicker.io/docs/security/
  filepicker.setKey('AUSwIq7mUSuenbIA4BtCWz')
