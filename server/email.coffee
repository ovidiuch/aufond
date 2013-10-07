# TODO move the default email address to a setting
DEFAULT_EMAIL_ADDRESS = 'Ovidiu Cherecheș <contact@aufond.me>'

# Reasonable limit for the the number of emails sent by a user per minute
EMAILS_PER_MINUTE = 20

# Records of the emails sent by each user are kept, in order to prevent abuse
emailSent = {}

@sendEmail = (params = {}) ->
  params.to ?= DEFAULT_EMAIL_ADDRESS
  params.from ?= DEFAULT_EMAIL_ADDRESS
  Email.send(params)

isAllowedToSendEmail = (params) ->
  ###
    TODO make this a more agnostic component if useful in other areas as well
  ###
  user = User.current()

  # Guest aren't allowed to send emails
  unless user?
    console.log("Guest user trying to send email: #{JSON.stringify(params)}")
    return false

  # Only root users should be able to send more than a number of emails in a
  # given day (since they can send out campaigns)
  return true if user.isRoot()

  username = user.get('username')
  now = Math.round(Date.now() / 1000)

  # If this is the first email from this user (for this server session)
  unless emailSent[username]?
    emailSent[username] = []
  userEmails = emailSent[username]

  if userEmails.length >= EMAILS_PER_MINUTE and
     userEmails[userEmails.length - EMAILS_PER_MINUTE] > now - 60
    console.log("#{username} trying to send more than #{EMAILS_PER_MINUTE} " +
                "emails in a minute: #{JSON.stringify(params)}")
    return false

  userEmails.push(now)
  return true

Meteor.methods
  sendEmail: (params) ->
    # Let other method calls from the same client start running,
    # without waiting for the email sending to complete.
    this.unblock()
    sendEmail(params) if isAllowedToSendEmail(params)

# XXX maybe this setting should be removed and set as an environment variable
process.env.MAIL_URL = Meteor.settings.MAIL_URL
