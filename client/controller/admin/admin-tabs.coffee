class @AdminTabs extends ReactiveTemplate
  template: Template.adminTabs

  events:
    'click .nav-tabs a': 'onClick'

  rendered: ->
    super(arguments...)
    @select(App.router.args.tab)

  select: (tab) ->
    @view.$el.find('.nav-tabs').find("a[data-tab-name=#{tab}]").tab('show')

  onClick: (e) =>
    e.preventDefault()
    # Update the browser URL with the selected tab and trigger a controller
    # change (that will consequently select the corresponding tab)
    tab = $(e.currentTarget).data('tab-name')
    App.router.navigate("admin/#{tab}", trigger: true)
