child_process = Npm.require('child_process')
fs = Npm.require('fs')

# This is the local path for dumping generated timeline files. It is a
# temporary buffer for before uploading them to CDN, but can be considered a
# side backup location. Timelines should never be served from here, though
exportPath = '.export~'

RegExp.escape = (str) ->
  ###
    Escape string for creating a RegExp object around it

    Example:
      pattern = new RegExp(RegExp.escape('url.html?var=val'))

    TODO move this somewhere global when needed again
  ###
  return str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

getExportName = (username) ->
  ###
    Unique user-based name for a static export
  ###
  return "#{username}-#{Date.now()}.html"

getExportPath = (name) ->
  ###
    Local, intermediary path for dumping exports after generating them
  ###
  return "#{process.cwd()}/#{exportPath}/#{name}"

parseGeneratedExport = (model, content) ->
  ###
    Parse and process the rendered export of a user timeline into a static file
    with no external dependencies

    TODO make URLs absolute
    TODO handle FontAwesome somehow...
    TODO embed images (using data:image/jpg?)
  ###
  model.save(status: 'Processing...')

  # Make all links absolute, in order to link back to the online profile in
  # case they are clicked
  content = content.replace /href="\/([^\/].+?)"/g, (match, url) ->
    url = Meteor.absoluteUrl(url)
    return "href=\"#{url}\""

  # Store all stylesheets found inside a list and remove then invidividually
  # as they are fetched asynchronously, thus knowing all stylesheets have been
  # loaded when the list is empty
  STYLESHEET_PATTERN = /<link rel="stylesheet" href="(.+?)">/g
  stylesheetsToParse = []

  content = content.replace STYLESHEET_PATTERN, (match, href) ->
    stylesheetsToParse.push(href)
    return "<style>#{href}</style>"

  # Fetch contents of each stylesheet individually, asynchronously, using Node
  # method of running a shell command
  for stylesheet in stylesheetsToParse
    # Create a closure for each stylesheet name, in order to bind it to its
    # asynchronously loaded contents
    do (stylesheet) ->
      # Stylesheet URL was already made absolute (see above)
      child = child_process.exec "curl #{stylesheet}",
        # Bind async callback into a Meteor Fibers environment
        Meteor.bindEnvironment (err, stdout, erderr) ->
          throw err if err?
          console.log("Fetched stylesheet for export: #{stylesheet}")

          # Track back initial stylesheet placeholder and inject its contents
          pattern = new RegExp(RegExp.escape "<style>#{stylesheet}</style>")
          content = content.replace(pattern, "<style>#{stdout}</style>")

          # Continue with the exporting process when all stylesheets have been
          # loaded and embedded into the static page
          stylesheetsToParse = _.without(stylesheetsToParse, stylesheet)
          storeStaticExport(model, content) unless stylesheetsToParse.length

        , (err) ->
          model.save(status: "#{err}")

storeStaticExport = (model, content) ->
  ###
    Store exported timeline to drive
  ###
  model.save(status: 'Saving...')

  fileName = getExportName(model.getUsername())
  filePath = getExportPath(fileName)

  fs.writeFile filePath, content,
    # Bind async callback into a Meteor Fibers environment
    Meteor.bindEnvironment (err) ->
      throw err if err?
      console.log("Successful timeline export: #{filePath}")
      uploadStaticExport(model, fileName, filePath)
    , (err) ->
      model.save(status: "#{err}")

uploadStaticExport = (model, fileName, filePath) ->
  ###
    Upload static export online, to CDN (Rackspace Files)
  ###
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
    console.log("Fetching timeline for export: #{url}")

    # Fetch url using Node method of running a shell command
    child = child_process.exec "curl #{url}",
      # Bind async callback into a Meteor Fibers environment
      Meteor.bindEnvironment (err, stdout, erderr) ->
        throw err if err?
        parseGeneratedExport(model, stdout)
      , (err) ->
        model.save(status: "#{err}")

    # Make sure not to return the ChildProcess object, because the method will
    # attempt to convert it into EJSON and an infinite loop will occur
    return null
