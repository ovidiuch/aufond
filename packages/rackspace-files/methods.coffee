###
  Check Racespace docs and cloudfiles Npm package for API info
    - http://docs.rackspace.com
    - https://github.com/nodejitsu/node-cloudfiles

  TODO keep an eye on pkgcloud, we should migrate once it has stable support
  for CDN files
  - https://github.com/nodejitsu/pkgcloud
###
containerName = 'aufond-export'
# XXX find a way to retrieve the container path dynamically, through the API
containerPath = 'http://a0ed08a7436682c32d8c-18919fda58f4c818d06f8d1b1da79260.r52.cf2.rackcdn.com'

@uploadRackspaceFile = (name, path, callback) ->
  # The Rackspace client needs to authenticate before doing any transaction
  client.setAuth (err) ->
    if err
      callback(err)
    else
      fileOptions =
        remote: name
        local: path
      client.addFile containerName, fileOptions, (err, uploaded) ->
        if err?
          callback(err)
        else
          callback(null, "#{containerPath}/#{name}")

# Init Rackspace client using cloudfiles Npm package
# TODO investigate ServiceNet transfering if uploading files to Rackspaces
# becomes a drag
client = Npm.require('cloudfiles').createClient
  auth:
    username: 'skidding'
    apiKey: 'f30940bbaa2ac6b9e0c8b6f88ab57b38'
