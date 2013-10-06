class @PasswordForm extends Form
  template: Template.passwordForm

  submit: ->
    data = @getDataFromForm()
    @updateFormData(data)

    # Validate user data beforehand
    error = null
    if not data.oldPassword and not data.newPassword
      error = 'Update _what_, exactly?'
    else if not data.newPassword
      error = "New password can't be empty"

    trackAction('change password', error: error)

    if error
      @onError(error)
    else
      Accounts.changePassword data.oldPassword, data.newPassword, (error) =>
        if error
          # XXX send custom error to users
          # XXX sometimes Meteor uses "message" instead of "reason"
          @onError(error.reason or error.message)
        else if _.isFunction(@onSuccess)
          @onSuccess()

  onSuccess: ->
    @update(success: 'Password changed successfully')
