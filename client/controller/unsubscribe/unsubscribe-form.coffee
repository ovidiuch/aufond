class @UnsubscribeForm extends ReactiveTemplate
  ###
    This form is fired automatically upon opening, and is used when a user
    follows the unsubscribe link from a notification email.

    It loads the user id arg from the URL, unsubscribes the corresponding user
    (if one is matched for that id) and lets them know using a short message.
  ###
  template: Template.unsubscribeForm

  created: ->
    super(arguments...)

    userId = App.router.args.id
    user = User.find(userId)

    args =
      userFound: user?

    if args.userFound
      # Server method for unsubscribing an user, since the isSubscribed
      # property isn't accessible from the client-side
      Meteor.call('unsubscribe', userId)
      trackAction('unsubscribe')
      # Display email in template to assure they're unsubcribed
      args.username = user.get('username')

    @update(args)
