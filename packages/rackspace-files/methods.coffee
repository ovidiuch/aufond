###
  Check Racespace docs and cloudfiles Npm package for API info
    - http://docs.rackspace.com
    - https://github.com/nodejitsu/node-cloudfiles

  TODO keep an eye on pkgcloud, we should migrate once it has stable support
  for CDN files
  - https://github.com/nodejitsu/pkgcloud
###
@uploadRackspaceFile = (name, path, callback) ->
  # The Rackspace client needs to authenticate before doing any transaction
  client.setAuth (err) ->
    if err
      callback(err)
    else
      fileOptions =
        remote: name
        local: path
      client.addFile rackspaceConfig.containerName, fileOptions, (err, uploaded) ->
        if err?
          callback(err)
        else
          callback(null, "#{rackspaceConfig.containerPath}/#{name}")

@removeRackspaceFile = (name, callback) ->
  # The Rackspace client needs to authenticate before doing any transaction
  client.setAuth (err) ->
    if err
      callback(err)
    else
      client.destroyFile rackspaceConfig.containerName, name, (err) ->
        # No argument marks a successful remove
        callback(err)

rackspaceConfig = Meteor.settings.Rackspace
if rackspaceConfig?
  # Init Rackspace client using cloudfiles Npm package
  # TODO investigate ServiceNet transfering if uploading files to Rackspaces
  # becomes a drag
  client = Npm.require('cloudfiles').createClient
    auth:
      username: rackspaceConfig.username
      apiKey: rackspaceConfig.apiKey
