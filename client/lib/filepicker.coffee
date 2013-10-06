class @FilePicker extends ReactiveTemplate
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

  @getResizedImageUrl: (url, options) ->
    ###
      Check possible options at
      https://developers.filepicker.io/docs/web/#fpurl-images
    ###
    args = ("#{k}=#{v}" for k, v of options)
    url += "/convert?#{args.join('&')}" if args.length
    return url

  template: Template.filePicker
  events:
    'click .button': 'onSelect'
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
  # Bypass options by setting them to "null". E.g.
  # {{getResizedImageUrl url null 250 'clip'}}
  options = {}
  options.w = width if width?
  options.h = height if height?
  options.fit = fit if fit?
  return FilePicker.getResizedImageUrl(url, options)


Meteor.startup ->
  # XXX enhance security if possible
  # https://developers.filepicker.io/docs/security/
  try filepicker.setKey(Meteor.settings.public.Filepicker.api_key)
