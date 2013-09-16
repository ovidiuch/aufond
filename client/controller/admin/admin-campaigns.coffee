Template.adminCampaigns.events
  'click .button-create,
   click .button-edit': (e) ->
    e.preventDefault()
    App.campaignModal.update($(e.currentTarget).data())

  'click .button-delete': (e) ->
    e.preventDefault()
    App.deleteCampaignModal.update($(e.currentTarget).data())

  'click .button-launch': (e) ->
    e.preventDefault()
    Meteor.call('launchCampaign', $(e.currentTarget).data('id'))

Template.adminCampaigns.campaigns = ->
  return Campaign.get().toJSON()
