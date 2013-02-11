# Append the radioactive controller container when the main layout renders for
# the first time
Template.controller.rendered = ->
  container = $(this.find '#content')
  return if container.children().length
  container.append(AufondController.createContainer())

Template.admin.events
  'click .post-btn': (e) ->
    e.preventDefault()
    postModal.update $(e.currentTarget).data()

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

postModal = null
Template.admin.rendered = ->
  modalContainer =  $(this.find '#post-modal')
  return if modalContainer.children().length
  postModal = new Modal(modalContainer)
