###
  Alter the global .button event handling and rely on "mouseup" events besides
  the "click" ones, in order to fix a bug related to intercepting mouse click
  events https://github.com/skidding/aufond/issues/33
###
onButtonMouseDown = (e) ->
  # Mark the beginning of a click
  $(e.currentTarget).data('_pressing', true)

onButtonMouseUp = (e) ->
  # Wait to see if a click event will follow this one, and similate it in
  # case it doesn't
  window.setTimeout ->
    # Trigger a manual click event if a natural one hasn't by now
    if $(e.currentTarget).data('_pressing')
      triggerClickEvent(e.currentTarget)

onButtonClick = (e) ->
  # Flag the button as clicked so the mouseup hack doesn't kick in anomore
  $(e.currentTarget).data('_pressing', false)

triggerClickEvent = (element) ->
  # XXX IE vs others
  if document.createEventObject
    element.fireEvent('onclick', document.createEventObject())
  else
    e = document.createEvent('HTMLEvents')
    e.initEvent('click', true, true)
    element.dispatchEvent(e)

Meteor.startup ->
  $(document).on('mousedown', '.button', onButtonMouseDown)
  $(document).on('mouseup', '.button', onButtonMouseUp)
  $(document).on('click', '.button', onButtonClick)
