Template.admin.events
  'click .btn-launch': (e) ->
    Aufond.router.navigate('', trigger: true)

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

  'click .btn-post': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postModal.reactiveBody.load(null)
    Aufond.postModal.update(data)

  'click .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postModal.reactiveBody.load(data.id)
    Aufond.postModal.update(data)

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.collection.remove({_id: data.id})

Template.admin.rendered = ->
  # XXX remove this and make post modal self contained
  if $(this.find '#post-modal').is(':empty')
    $(this.find '#post-modal').append(Aufond.postModal.createReactiveContainer())

Template.admin.entries = ->
  return Entry.collection.find {}

Meteor.startup ->
  postForm = new Form
    templateName: 'post_form'
    collection: Entry

  Aufond.postModal = new Modal
    reactiveBody: postForm
    onSubmit: (modal) ->
        postForm.submit(-> modal.close())
