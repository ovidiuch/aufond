class @IdeaForm extends Form
  template: Template.ideaForm

  submit: ->
    trackAction('send idea')
    super(arguments...)

  onSuccess: ->
    @update(success: "Duly noted!", false)
