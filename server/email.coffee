EMAILS_PER_DAY = 2
emailSent = {}

allowedToSendEmail = (user) ->
  ###
    Users should be limited to a number of emails per day, otherwise the email
    server method can be abused by mofos

    TODO: Make this a more agnostic component if useful in other areas as well
  ###
  user = User.current()
  # Don't allow guests to send emails at all
  return false unless user?
  # Only root users should be able to send more than a number of emails in a
  # given day (since they can send out campaigns)
  return true if user.isRoot()

  username = user.get('username')
  # If this is the first email from this user
  unless emailSent[username]?
    emailSent[username] = {}

  emailByUser = emailSent[username]
  now = Date.now()
  today = now - (now % 86400)
  # If this is the first email from this user, today
  unless emailByUser[today]?
    emailByUser[today] = 0

  return ++emailByUser[today] <= EMAILS_PER_DAY

Meteor.methods
  sendEmail: (to, from, subject, text) ->
    unless allowedToSendEmail()
      console.log('Refusing to send email!')
      return

    # Let other method calls from the same client start running,
    # without waiting for the email sending to complete.
    this.unblock()

    process.env.MAIL_URL = Meteor.settings.MAIL_URL
    Email.send
      to: to
      from: from
      subject: subject
      text: text
