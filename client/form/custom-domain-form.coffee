class @CustomDomainForm extends Form
  template: Template.customDomainForm

  submit: ->
    trackAction('update custom domain')
    super(arguments...)

  onSuccess: ->
    @update(success: "Custom domain set successfully", true)
