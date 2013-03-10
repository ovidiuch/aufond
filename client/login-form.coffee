class LoginForm extends Form
  template: Template.login_form

  submit: (onSuccess) ->
    data = @getDataFromForm()

    Meteor.loginWithPassword data.handle, data.password, (error) =>
      if error
        # XXX send custom error to users
        @update(error: error.reason, true)
      else
        onSuccess()
