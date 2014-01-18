class @UserDomainRouter extends @Router
  ###
    Custom router for loading a user timeline directly, for a custom domain
  ###
  routes:
    # Only the timeline of this user will be visible with this Router instance
    '*path': 'timeline'

  constructor: (controller, username) ->
    @username = username
    super(arguments...)

  timeline: (path) ->
    # On custom user domains the url path is an entry slug directly, the
    # username is drawn from the domain name
    @changeController
      name: 'timeline'
      username: @username
      slug: path

