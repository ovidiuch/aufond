class @AdminCampaigns extends AdminTab
  template: Template.adminCampaigns

  constructor: ->
    @events = _.extend({'click .button-launch': 'onLaunch'}, @events)
    super(arguments...)

  onLaunch: (e) =>
    e.preventDefault()
    Meteor.call('launchCampaign', $(e.currentTarget).data('id'))
