# Append the radioactive controller container when the main layout renders for
# the first time
Template.controller.rendered = ->
  container = $(this.find('#content'))
  return if container.children().length
  container.append(Controller.createContainer())
