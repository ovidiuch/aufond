Template.admin.events
  'click .btn-launch': (e) ->
    Aufond.router.navigate('', trigger: true)

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

  'click .btn-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postModal.loadPost(null)
    Aufond.postModal.update(data)

  'click .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postModal.loadPost(data.id)
    Aufond.postModal.update(data)

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.collection.remove({_id: data.id})

Template.admin.entries = ->
  return Entry.collection.find {}
