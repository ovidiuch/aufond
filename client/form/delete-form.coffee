class @DeleteForm extends Form
  # The submit button for a delete form is usually a red, ".danger" one
  submitButton: '.button-danger'

  submit: ->
    unless @params.model?
      throw new Error "Delete form has no model attached"
    unless @model?
      throw new Error "Delete form has no id for #{@params.model} model"

    @model.destroy (error) =>
      if error
        # XXX send custom error to users
        # XXX sometimes Meteor uses "message" instead of "reason"
        @onError(error.reason or error.message)
      else if _.isFunction(@onSuccess)
        @onSuccess()
