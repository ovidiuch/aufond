Template.adminTabs.events
  'click .nav-tabs a': (e) ->
    e.preventDefault()

    # Update the browser URL with the selected tab
    tab = $(e.currentTarget).data('tab-name')
    App.router.navigate("admin/#{tab}", trigger: true)

Template.adminTabs.rendered = ->
  # Select current tab (taken from current URL)
  tab = App.router.args.tab
  $(@find '.nav-tabs').find("a[data-tab-name=#{tab}]").tab('show')
