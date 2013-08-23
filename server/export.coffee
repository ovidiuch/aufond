child_process = Npm.require('child_process')
fs = Npm.require('fs')

# This is the local path for dumping generated timeline files. It is a
# temporary buffer for before uploading them to CDN, but can be considered a
# side backup location. Timelines should never be served from here, though
exportPath = '.export~'

getBasePath = ->
  ###
    XXX because the path we get is the one from where the process is running,
    the current way of extracting the base path is to strip it from after (and
    including) the .meteor folder (or .bundle in production), which we know is
    in a root folder in the project. The process runs from:
    - .meteor/local/build/programs/server in development
    - .bundle/programs/server in production
  ###
  return Npm.require('path').resolve('.').replace(/\/\.(meteor|bundle).*$/, '')

getExportName = (username) ->
  ###
    Unique user-based name for a static export
  ###
  return "#{username}-#{Date.now()}.pdf"

getExportPath = (name) ->
  ###
    Local, intermediary path for dumping exports after generating them
  ###
  return "#{getBasePath()}/#{exportPath}/#{name}"

uploadStaticExport = (model, fileName, filePath) ->
  ###
    Upload static export online, to CDN (Rackspace Files)
  ###
  console.log("Uploading export #{fileName} to static CDN...")
  model.save(status: 'Uploading...')

  uploadRackspaceFile fileName, filePath,
    # Bind async callback into a Meteor Fibers environment
    Meteor.bindEnvironment (err, fileUrl) ->
      throw err if err?
      model.save
        status: 'Done.'
        url: fileUrl
      console.log("Successfully uploaded export to Rackspace: #{fileUrl}")
    , (err) ->
      model.save(status: "#{err}")

Meteor.methods
  generateExport: (exportId) ->
    ###
      Use cURL to scrape a user timeline and hand it to an export model

      TODO implement frequency limit (per user)
      TODO investigate unblock
    ###
    console.log("Generating export: #{exportId}")
    model = Export.find(exportId)
    return unless model?

    model.save(status: 'Generating...')
    username = model.getUsername()

    # Generate crawlable (courtecy of spiderable plugin) url for the requested
    # user timeline (with contact section opened by default)
    url = Meteor.absoluteUrl("#{username}/contact?_escaped_fragment_=")

    # Store export locally before uploading into a static CDN
    fileName = getExportName(model.getUsername())
    filePath = getExportPath(fileName)

    # We have a custom phantomjs script for exporting .pdf, with hardcoded
    # parameters and tweaks
    exportScript = "#{getBasePath()}/server/.phantomjs-scripts/export-pdf.js"

    console.log("Exporting timeline #{url} to #{filePath}")
    # Use Node method for running a shell command
    child = child_process.exec "phantomjs #{exportScript} #{url} #{filePath}",
      # Bind async callback into a Meteor Fibers environment
      Meteor.bindEnvironment (err) ->
        throw err if err?
        # Store the file name inside the export model as soon as the file is
        # created
        model.save(fileName: fileName)
        uploadStaticExport(model, fileName, filePath)
      , (err) ->
        model.save(status: "#{err}")

    # Make sure not to return the ChildProcess object, because the method will
    # attempt to convert it into EJSON and an infinite loop will occur
    return null
