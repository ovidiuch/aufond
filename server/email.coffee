# XXX should implement email frequency limit
Meteor.methods
  sendEmail: (to, from, subject, text) ->
    # Let other method calls from the same client start running,
    # without waiting for the email sending to complete.
    this.unblock()

    # XXX you can only send up to 200 emails a day using the free Mailgun plan
    process.env.MAIL_URL = "smtp://postmaster%40aufond.mailgun.org:2d4q0qjzbg08@smtp.mailgun.org:465"
    Email.send
      to: to
      from: from
      subject: subject
      text: text
