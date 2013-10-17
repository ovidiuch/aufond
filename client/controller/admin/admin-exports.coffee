class @AdminExports extends AdminTab
  template: Template.adminExports

  decorateTemplateData: (data) ->
    data = super(data)
    # Since creating export has no actual form, we use the Session object for
    # reactive template updates on possible export errors
    data.exportError = Session.get('exportError')
    return data

  onCreate: (e) =>
    e.preventDefault()
    # Exports don't have any options for now
    new Export().save (err) ->
      # Store the error in the Session object to render it reactively in the
      # template
      Session.set('exportError', err)
      trackAction('export', error: err)

