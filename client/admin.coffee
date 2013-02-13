Template.admin.events
  'click .launch-btn': (e) ->
    Aufond.router.navigate('', trigger: true)

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

  'click .post-btn': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    data.body = Template.post_form()
    Aufond.postModal.update(data)

Template.admin.rendered = ->
  # This is OK because the modal will ignore the same element called
  # consecutively
  Aufond.postModal.attach($(this.find '#post-modal'))

Template.admin.entries = ->
  return Entries.find {}

Meteor.startup ->
  Aufond.postModal = new Modal (modal) ->
    data = modal.$container.find('form').serializeObject()
    if data._id?
      # XXX edit
    else
      Entries.insert(data)
    modal.close()
