class @IdeaForm extends Form
  template: Template.ideaForm

  submit: ->
    # Track ideas in Mixpanel
    mixpanel.track('send idea')
    super(arguments...)

  onError: (error) ->
    # Make all errors look like warnings for a friendlier response
    @update(warning: error, true)

  onSuccess: ->
    @update(success: "Duly noted!", false)
