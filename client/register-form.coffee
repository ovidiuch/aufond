class RegisterForm extends Form
  templateName: 'register_form'

  submit: (onSuccess) ->
    data = @getDataFromForm()
    options =
      username: data.username
      email: data.email
      password: data.password
      profile:
        name: data.name

    # Validate user data beforehand
    error = null
    if not options.username
      error = 'Please choose a neat username for your account'
    else if options.username.length < 2
      error = 'One more char, bro'
    else if not options.username.match /^[a-z0-9._-]+$/i
      error = 'What is _that_? Please use **a-z0-9._-** chars for your username'
    else if User.find(username: options.username)
      error = 'Username is already taken :('
    else if not options.password
      error = 'Come on, you need a password for _any_ account'

    if error
      @update(error: error, true)
    else
      Accounts.createUser options, (error) =>
        if error
          # XXX send custom error to users
          @update(error: error.reason, true)
        else
          onSuccess()
