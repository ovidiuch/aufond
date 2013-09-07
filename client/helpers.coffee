Handlebars.registerHelper 'match', (options) ->
  # Match a key-value hash against the current scope and act as an if/else
  # block, depending on their equality
  for k, v of options.hash
    if v isnt this[k]
      # Return false if any of the compared keys have a different value in the
      # current scope
      return options.inverse(this)
  return options.fn(this)

Handlebars.registerHelper 'markdown', (text, options) ->
  return '' unless text?
  if options.hash.root
    # Extract the root element of each block (which would be paragraphs) and
    # replace it with a different DOM element
    tree = markdown.toHTMLTree(text)
    # Ignore the first tree element, which is "html"
    block[0] = options.hash.root for block in tree[1...]
    return markdown.renderJsonML(tree)
  else
    return markdown.toHTML(text)

Handlebars.registerHelper 'timeago', (time) ->
  # Account for the client-server time differences and provide a relevant "time
  # ago" for the current user
  time += App.serverTimeOffset if App.serverTimeOffset?
  return moment(time).fromNow()

Handlebars.registerHelper 'formatDate', (time, format) ->
  return moment(time).format(format)

Handlebars.registerHelper 'loggedIn', ->
  return Meteor.user()?.username

Handlebars.registerHelper 'isRootUser', ->
  return User.current()?.isRoot()

Handlebars.registerHelper 'inController', (name) ->
  return App.router.args.name is name

Handlebars.registerHelper 'entryUrl', (slug) ->
  ###
    Create a relative (no domain) url path to a certain timeline entry.
    The challange is knowing whether or not to add the username prefix,
    assuming that we support user domains. XXX we don't, improve this logic
    and make the username optional once we do
  ###
  username = App.router.args.username
  return "/#{username}/#{slug}"

Handlebars.registerHelper 'profileLinkAddress', (address) ->
  ###
    Ensure a default protocol for links without one. So far we only add http://
    to ones that start with "www."
  ###
  return address.replace(/^www./, 'http://www.')

Handlebars.registerHelper 'profileLinkValue', (address) ->
  ###
    Extract the protocol from a user link. E.g. mailto: from email, http://
    from a link, etc.
  ###
  return address.replace(/^.+?:(\/\/)?/, '')

Handlebars.registerHelper 'isReadyExport', (model) ->
  ###
    XXX this is not extendable but we'll cross any other bridge when we need
    to, so far we need to remove the ready state when it starts getting removed
    (i.e. when it changes its status from "Done." to "Removing...")
  ###
  return model.url and model.status is "Done."
