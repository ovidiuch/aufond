Template.admin.events
  'click .post-btn': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postModal.update(data)

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

Template.admin.rendered = ->
  # This is OK because the modal will ignore the same element called
  # consecutively
  Aufond.postModal.attach($(this.find '#post-modal'))

Meteor.startup ->
  # XXX add callback on primary btn
  Aufond.postModal = new Modal()
