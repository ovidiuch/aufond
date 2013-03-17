class Timeline

  @rendered: (container) ->
    @$container = $(container)
    this.adjustHeader()
    this.setupBubbles(12)
    # Go to opened path directly (no animation)
    # XXX should wait until DOM is completely ready (fonts, etc.)
    Timeline.goTo(App.router.args.slug, false)

  @adjustHeader: ->
    ###
      Make timeline header 100% height
    ###
    windowHeight = Math.max($(window).height(), 400)
    top = windowHeight / 2 - 110
    @$container.find('.header').css
      paddingTop: top
      height: windowHeight - top - 50

  @setupBubbles: (offset) ->
    @$container.find('.year .bullet').bubble
      time: 0.1
      offset: offset
    @$container.find('.post .bullet, .header .bullet').bubble
      time: 0.1
      offset: offset
      target: '.head'

  @goTo: (slug, animate = true) ->
    # Scroll to a given slug
    if slug
      @scrollTo($("#timeline-#{slug}"), if animate then 0.1 else 0)

  @scrollTo: ($element, duration) ->
    # Make sure element exists
    return unless $element.length
    # Get the current scroll position in order to make a transitioned movement
    startScroll = $(window).scrollTop()
    $(this).play
      time: duration
      onFrame: (ratio) ->
        # Fetch the offset of the targeted element with every frame, in order
        # to make sure we're landing right in case it's moving its position for
        # whatever reason
        diff = $element.offset().top - startScroll
        $('html, body').scrollTop(startScroll + ratio * diff)

  @openLink: (e) =>
    e.preventDefault()
    # Toggle link path if currently on it
    path = @getPathByTarget(e.currentTarget)
    if path is @getCurrentPath()
      path = @getDefaultPath()
    App.router.navigate(path, trigger: true)

  @getPathByTarget: (target) ->
    slug = $(target).data('slug')
    return "#{App.router.args.username}/#{slug}"

  @getCurrentPath: ->
    path = App.router.args.username
    if App.router.args.slug
      path = "#{path}/#{App.router.args.slug}"
    return path

  @getDefaultPath: ->
    return App.router.args.username


Template.timeline.events
  'click .link': Timeline.openLink

Template.timeline.rendered = ->
  Timeline.rendered(this.firstNode)

Template.timeline.entries = ->
  # Get entries of current user only
  return Entry.getByYears(App.router.args.username)

Template.timeline.iconClass = (icon) ->
  return icon or 'icon-circle'
