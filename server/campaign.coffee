Meteor.methods
  launchCampaign: (id) ->
    ###
      Launch a campaign by sending an email to all currently subscribed users.
      In order to see the progress the list of emails that have successfully
      received the message will be updated into the campaign document
    ###
    campaign = Campaign.find(id)
    return unless campaign?

    # Make sure we don't send a campaign to the same person more than once
    alreadySentTo = campaign.get('sentTo')

    # Form a list of recipient emails that are eligible of reciving this
    # Campaign: those that are currently subscribed.
    subscribedUsers = User.get(isSubscribed: true)
    recipients = {}
    for user in subscribedUsers
      userId = user.get('_id')
      continue if userId in alreadySentTo
      recipients[userId] = user.getEmailField()

    console.log("Sending campaign #{campaign.get('subject')} to " +
                "#{_.keys(recipients).length} recipients:", recipients)

    for userId, emailField of recipients
      console.log("Sending email to #{emailField}")
      Meteor.call('sendEmail',
                  emailField,
                  'Ovidiu Cherecheș <contact@aufond.me>',
                  campaign.get('subject'),
                  campaign.getMessage(userId))
      # Append the userId to the list of confirmed recipients
      campaign.save
        sentTo: campaign.get('sentTo').concat([userId])

    console.log("Finished sending campaign #{campaign.get('subject')}.")
