class @EmailForm extends Form
  template: Template.emailForm

  submit: ->
    # Track email changes in Mixpanel
    mixpanel.track('change email')
    super(arguments...)

  onSuccess: ->
    @update(success: "Email changed successfully", true)

  updateModel: (data) ->
    # Don't do anything with the new email if it's the same as the current one
    unless data.email is @model.getEmail()
      # Preserve the standard Meteor email storage inside user documents
      @model.set 'emails', [
        address: data.email
        verified: false
      ]
