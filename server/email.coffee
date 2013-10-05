# XXX should implement email frequency limit
Meteor.methods
  sendEmail: (to, from, subject, text) ->
    # Let other method calls from the same client start running,
    # without waiting for the email sending to complete.
    this.unblock()

    process.env.MAIL_URL = Meteor.settings.MAIL_URL
    Email.send
      to: to
      from: from
      subject: subject
      text: text
