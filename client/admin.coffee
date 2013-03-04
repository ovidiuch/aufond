Template.admin.events
  'click .btn-timeline': (e) ->
    username = Meteor.user().username
    Aufond.router.navigate("#{username}", trigger: true)

  'click .btn-logout': (e) ->
    Meteor.logout (error) ->
      if error
        # XXX handle logout error
      else
        Aufond.router.navigate('', trigger: true)

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
  # Get own entries only
  filter =
    createdBy: Meteor.userId()
  return Entry.get(filter, sort: {time: -1}).toJSON()

Template.admin.timeago = (time) ->
  return moment(time).fromNow()
