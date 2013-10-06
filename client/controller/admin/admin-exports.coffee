Template.adminExports.events
  'click .button-create': (e) ->
    e.preventDefault()
    # Exports don't have any options for now
    new Export().save (err) ->
      # Store the error in the Session object to render it reactively in the
      # template
      Session.set('exportError', err)
      trackAction('export', error: err)

  'click .button-delete': (e) ->
    e.preventDefault()
    App.deleteExportModal.update($(e.currentTarget).data())

Template.adminExports.exports = ->
  # Fetch export of the current user in descending order of creation time
  return Export.get(
    createdBy: Meteor.userId(), {sort: {createdAt: -1}}
  ).toJSON()

Template.adminExports.exportError = ->
  # Since creating export has no actual form, we use the Session object for
  # reactive template updates on possible export errors
  return Session.get('exportError')
