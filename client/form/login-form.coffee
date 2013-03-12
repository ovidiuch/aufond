class LoginForm extends Form
  template: Template.loginForm

  submit: ->
    data = @getDataFromForm()

    Meteor.loginWithPassword data.handle, data.password, (error) =>
      if error
        # XXX send custom error to users
        @update(error: error.reason, true)
      else if _.isFunction(@onSuccess)
        @onSuccess()
