class @EmailForm extends Form
  template: Template.emailForm

  submit: ->
    @clearStatus()
    email = @getDataFromForm().email

    # Don't do anything with the new email if it's the same as the current one
    unless email is @model.get('emails')?[0].address
      # Preserve the standard Meteor email storage inside user documents
      @model.set 'emails', [
        address: email
        verified: false
      ]

    # Update the User document normally
    @model.save (error, model) =>
      if error
        @onError(error)
      else if _.isFunction(@onSuccess)
        @onSuccess()

  onSuccess: ->
    @update(success: "Email changed successfully", true)
