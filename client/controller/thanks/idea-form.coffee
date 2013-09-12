class @IdeaForm extends Form
  template: Template.ideaForm

  submit: ->
    # Track ideas in Mixpanel
    mixpanel.track('send idea')
    super(arguments...)

  onSuccess: ->
    @update(success: "Duly noted!", false)
