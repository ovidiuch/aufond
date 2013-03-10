Template.admin.events
  'click .btn-timeline': (e) ->
    username = Meteor.user().username
    App.router.navigate("#{username}", trigger: true)

  'click .btn-logout': (e) ->
    Meteor.logout (error) ->
      if error
        # XXX handle logout error
      else
        App.router.navigate('', trigger: true)

  'click .nav-tabs a': (e) ->
    e.preventDefault()

    # Update the browser URL with the selected tab
    tab = $(e.currentTarget).data('tab-name')
    App.router.navigate("admin/#{tab}", trigger: true)

  'click #entries .btn-post,
   click #entries .btn-edit': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    App.postModal.update(data)

  'click #entries .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    Entry.remove(data.id)

  'click #users .btn-delete': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).data()
    # XXX delete without warning
    User.remove(data.id)

Template.admin.rendered = ->
  # Select current tab (taken from current URL)
  tab = App.router.args.tab
  $(this.find '.nav-tabs').find("a[data-tab-name=#{tab}]").tab('show')

Template.admin.postModal = ->
  module: PostModal

Template.admin.entries = ->
  # Get own entries only
  filter =
    createdBy: Meteor.userId()
  return Entry.get(filter, sort: {time: -1}).toJSON()

Template.admin.timeago = (time) ->
  return moment(time).fromNow()

Template.admin.passwordForm = ->
  module: PasswordForm

Template.admin.users = ->
  return User.get().toJSON()

Template.admin.isRootUser = ->
  return User.current()?.isRoot()
