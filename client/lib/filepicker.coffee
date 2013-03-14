class FilePicker extends ReactiveTemplate
  template: Template.filePicker

  events:
    'click .btn': 'onSelect'

  # Default options
  options: {}

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
    filepicker.pick(@options, @onSuccess)

  onSuccess: (FPFile) =>
    # Refresh template with the received url as the value
    @update(value: FPFile.url, true)


Meteor.startup ->
  # XXX enhance security if possible
  # https://developers.filepicker.io/docs/security/
  filepicker.setKey('AUSwIq7mUSuenbIA4BtCWz')
