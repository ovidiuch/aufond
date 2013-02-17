Template.admin.events
  'click .btn-launch': (e) ->
    Aufond.router.navigate('', trigger: true)

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

  'click .btn-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postForm.update({})
    Aufond.postModal.update(data)

  'click .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # Extract entry by id
    entry = Entries.findOne(_id: data.id)
    return unless entry?
    Aufond.postForm.update(entry)
    Aufond.postModal.update(data)

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entries.remove({_id: data.id})

Template.admin.rendered = ->
  # This is OK because the modal will ignore the same element called
  # consecutively
  Aufond.postModal.attach($(this.find '#post-modal'))

Template.admin.entries = ->
  return Entries.find {}

Meteor.startup ->
  Aufond.postForm = new Form 'post_form'
  Aufond.postModal = new Modal Aufond.postForm,
    onRender: (modal) ->
      # Focus on first form input when modal opens. Make sure to remove any
      # previously set events in case the template renders multiple times
      modal.$container.off('shown').on 'shown', ->
        $(this).find('input:not([type=hidden])').first().focus()

    onSubmit: (modal) ->
      data = modal.$container.find('form').serializeObject()
      if data._id?
        Entries.update({_id: data._id}, data)
      else
        Entries.insert(data)
      modal.close()
