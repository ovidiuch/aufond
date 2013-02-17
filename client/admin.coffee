Template.admin.events
  'click .btn-launch': (e) ->
    Aufond.router.navigate('', trigger: true)

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

  'click .btn-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postModal.reactiveObject.update({})
    Aufond.postModal.update(data)

  'click .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # Extract entry by id
    entry = Entry.collection.findOne(_id: data.id)
    return unless entry?
    Aufond.postModal.reactiveObject.update(entry)
    Aufond.postModal.update(data)

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.collection.remove({_id: data.id})

Template.admin.rendered = ->
  # This is OK because the modal will ignore the same element called
  # consecutively
  Aufond.postModal.attach($(this.find '#post-modal'))

Template.admin.entries = ->
  return Entry.collection.find {}

Meteor.startup ->
  Aufond.postModal = new Modal(new Form('post_form'),
    onRender: (modal) ->
      # Focus on first form input when modal opens. Make sure to remove any
      # previously set events in case the template renders multiple times
      modal.$container.off('shown').on 'shown', ->
        $(this).find('input:not([type=hidden])').first().focus()

    onSubmit: (modal) ->
      data = modal.$container.find('form').serializeObject()
      if data._id?
        Entry.collection.update({_id: data._id}, data)
        modal.close()
      else
        entry = new Entry(data)
        entry.save {},
          success: (model, response) ->
            modal.close()
          error: (model, error) ->
            modal.reactiveObject.update(error: error)
  )
