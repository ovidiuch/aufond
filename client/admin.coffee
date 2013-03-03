Template.admin.events
  'click .btn-launch': (e) ->
    Aufond.router.navigate("#{Meteor.userId()}", trigger: true)

  'click .nav-tabs a': (e) ->
    e.preventDefault()
    $(this).tab 'show'

  'click .btn-post,
   click .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    Aufond.postModal.update(data)

  'click .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.remove(data.id)

Template.admin.entries = ->
  return Entry.get({}, sort: {time: -1}).toJSON()

Template.admin.timeago = (time) ->
  return moment(time).fromNow()
