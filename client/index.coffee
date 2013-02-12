# We need a global object to attach main modules to
window.Aufond = Aufond = {}

# Append the radioactive controller container when the main layout renders for
# the first time
Template.controller.rendered = ->
  return if @hasContent
  @hasContent = true
  $(this.find '#content').append(Aufond.controller.createReactiveContainer())
