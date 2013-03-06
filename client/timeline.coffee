Template.timeline.entries = ->
  # Get entries of current user only
  return Entry.getByYears(Aufond.controller.args.username)

Template.timeline.iconClass = (icon) ->
  return icon or 'icon-circle'

Template.timeline.rendered = ->
  $(this.firstNode).find('.year .bullet').bubble
    time: 0.1
    offset: 16
  $(this.firstNode).find('.post .bullet').bubble
    time: 0.1
    offset: 16
    target: '.head'
