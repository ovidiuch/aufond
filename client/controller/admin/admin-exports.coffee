Template.adminExports.events
  'click .button-create': (e) ->
    e.preventDefault()
    # Export don't have any options for now
    new Export().save()

  'click .button-delete': (e) ->
    e.preventDefault()
    App.deleteExportModal.update($(e.currentTarget).data())

Template.adminExports.exports = ->
  # Fetch export of the current user in descending order of creation time
  return Export.get(
    createdBy: Meteor.userId(), {sort: {createdAt: -1}}
  ).toJSON()
