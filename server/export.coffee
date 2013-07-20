child_process = Npm.require('child_process')
fs = Npm.require('fs')

exportPath = '.export~'

getExportName = (username) ->
  return "#{username}-#{Date.now()}.html"

getExportPath = (name) ->
  return "#{process.cwd()}/#{exportPath}/#{name}"

Meteor.methods
  exportTimeline: (username) ->
    ###
      Export a static version of a user's timeline, w/out any external links or
      dependencies, making it viewable offline

      TODO implement frequency limit (per user)
    ###
    user = User.find(username: username)
    return unless user?

    # Generate crawlable (courtecy of spiderable plugin) url for the requested
    # user timeline (with contact section opened by default)
    url = Meteor.absoluteUrl("#{username}/contact?_escaped_fragment_=")
    console.log("Fetching timeline for export: #{url}")

    # Fetch url using Node method of running a shell command
    child = child_process.exec "curl #{url}", (err, stdout, stderr) ->
      if err?
        throw new Meteor.Error(500, "Error fetching timeline: #{err}")
      else
        htmlContent = stdout
        # TODO fetch external links and embed them inline, such as CSS files

        # Store exported timeline to drive
        fileName = getExportName(username)
        filePath = getExportPath(fileName)
        fs.writeFileSync(filePath, htmlContent)
        console.log("Successful timeline export: #{filePath}")

        # Upload static file to CDN
        uploadRackspaceFile fileName, filePath, (err, fileURL) ->
          if err?
            throw new Meteor.Error(500, "Error uploading to Rackspace: #{err}")
          console.log("Successfully uploaded export to Rackspace: #{fileURL}")

    # Make sure not to return the ChildProcess object, because the method will
    # attempt to convert it into EJSON and an infinite loop will occur
    return null
