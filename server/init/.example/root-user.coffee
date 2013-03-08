# This is an example init server script, move this outside the .example folder
# and customize it to your needs to activate it (it will be gitignored)
Meteor.startup ->
  # Make sure the root user is not already created
  # Warning: Having the "admin" username, this root user won't be able to have
  # a timeline attached to it, so change it to something else if you intend to
  # use it as a regular user as well
  username = 'admin'
  if not User.find(username: username)
    console.log "Creating root user with '#{username}' handle..."

    userId = Accounts.createUser
      username: username
      email: 'admin@mail.com'
      password: 'changemepls'
      profile:
        name: 'Ovidiu Cherecheș'

    # Mark newly-added user as root (can't be done from client)
    user = User.find(userId)
    user.save {isRoot: true}, (error, user) ->
      if error
        console.log "Error #{error}"
      else
        console.log 'Done.'
