class @Timeline

  @rendered: (container) ->
    @$container = $(container)
    @adjustHeader()
    @setupBubbles()
    # TODO create own class for carousels to manage all set of images
    # independently, including their preloading
    @setupImageCarousels()
    @bindWindowEvents()
    # Go to opened path directly (no animation)
    # XXX should wait until DOM is completely ready (fonts, etc.)
    @goTo(App.router.args.slug, false)
    # XXX run with the next event loop to make sure all the CSS properties are
    # set w/out transitions at init (removing .loading class enables them)
    setTimeout(=> @$container.removeClass('loading'))

  @destroyed: ->
    @unbindWindowEvents()

  @bindWindowEvents: ->
    # XXX some events cannot be set locally and have to be attached on the
    # global document or window, but we need to take extra care in removing
    # them after this template is destroyed and also never setting them more
    # than once
    @unbindWindowEvents()

    $(window).on('resize', @onWindowResize)
    $(document).on('keyup', @onKeyUp)

  @unbindWindowEvents: ->
    $(window).off('resize', @onWindowResize)
    $(document).off('keyup', @onKeyUp)

  @onWindowResize: =>
    @adjustHeader()
    @adjustImageCarousels()

  @onKeyUp: (e) =>
    # ESCAPE key
    if e.keyCode is 27
      @untoggleActiveEntry()
    # LEFT ARROW OR J key
    else if e.keyCode in [37, 74]
      @prevEntry()
    # RIGHT ARROW or K key
    else if e.keyCode in [39, 75]
      @nextEntry()

  @adjustHeader: ->
    ###
      Make timeline header 100% height
    ###
    $header = @$container.find('.header')

    # Detect the height of the header in its current state
    headerHeight = $header.find('.head').outerHeight()
    # Set a minimum top and bottom margin of 150px. 50px from the bottom will
    # go to the peeking year bubble
    minTop = minBottom = 150
    # Only take content height into consideration if visible (when the header
    # is active)
    if $header.hasClass('active')
      # XXX subtract 60px of the content height because the avatar bubble
      # overlaps with 60px over it
      headerHeight += @getPostContentHeight($header) - 60
      # No need for a min top margin when the header content is open
      minTop = 0

    # Make sure things don't overlap when the window is smaller than the
    # header, by enforcing the min top & bottom margins
    windowHeight =
      Math.max($(window).height(), headerHeight + minTop + minBottom)
    availableHeight = windowHeight - headerHeight
    top = Math.min(availableHeight / 2, availableHeight - minBottom)

    # Height and padding of header entry use CSS transitions and will change
    # gracefully and in sync
    $header.css
      paddingTop: top
      # XXX subtract 50px because we want to see a peek of last year's bullet
      height: windowHeight - top - 50

  @setupBubbles: ->
    @$container.find('.year .bullet').bubble
      time: 0.1
      offset: 10
    @$container.find('.header .bullet').bubble
      time: 0.1
      offset: 10
      target: '.head'
    @$container.find('.post .bullet').bubble
      time: 0.1
      offset: 8
      target: '.head'
    @$container.find('.header .links a').bubble
      time: 0.1
      offset: 8

  @setupImageCarousels: ->
    # Setup the image carousels as their images load
    @$container.find('.image-wrap img').load ->
      Timeline.adjustImageCarousel($(this).closest('.image-wrap'))

  @adjustImageCarousels: ->
    # Adjust all image carousels (triggered on window resize)
    @$container?.find('.image-wrap').each (i, wrapper) =>
      @adjustImageCarousel($(wrapper))

  @adjustImageCarousel: ($wrapper) ->
    ###
      This can be triggered by
      - an image that finished loading
      - a browser resize
      and does the following:
      - adjust the mask of a carousel as half the timeline's width
      - sets the width of a carousel's list based on its child images
    ###
    windowWidth = $(window).width()
    # XXX determine whether we are on mobile or desktop view
    onExpandedLayout = windowWidth >= 1208

    # Determine the width of the entire carousel by summing up the widths of
    # all its images
    carouselWidth = 0
    $wrapper.find('img').each((i, img) -> carouselWidth += $(img).width())

    if onExpandedLayout
      # XXX set it to half the timeline width and retract the width of the
      # timeline bar
      availableWidth = (windowWidth - 6) / 2
      # XXX the carousel width must not be smaller then the available one in
      # expanded view, in order for left-sided carousels to have their images
      # reach the timeline bar on their side
      carouselWidth = Math.max(carouselWidth, availableWidth)
    else
      availableWidth = windowWidth
      # Center the carousel horizontally when its entire image list doesn't
      # cover the available width
      if carouselWidth < availableWidth
        availableWidth -= availableWidth - carouselWidth

    # Let the carousel flow naturally (using CSS rules) until there is at least
    # one image loaded. When loading static pages using ?_escaped_fragment_=
    # the spiderable plugin doesn't wait for the images to load, so we need to
    # preserve the default carousel width of 100%, so that the images at least
    # be partially visible when loading ulteriorly in a static html export
    return unless carouselWidth > 0

    # Apply detected sizes to DOM nodes
    $wrapper.find('.viewport').width(availableWidth)
    $wrapper.find('ul').width(carouselWidth)

    # XXX make sure the carousels of even entries (left-handed) start their
    # scrolling position from right to left
    if onExpandedLayout and $wrapper.closest('.entry').hasClass('even')
      $wrapper.find('.viewport').scrollLeft(availableWidth)

  @untoggleActiveEntry: (e) =>
    @toggleEntry(@$container.find('.entry.active'))

  @prevEntry: ->
    ###
      Select the previous entry if an active one exists, otherwise start
      navigation by making the closest entry to the user active
    ###
    $active = @$container.find('.active')
    if $active.length
      $entry = $active.nextAll('.entry:not(.year):first')
    else
      $entry = @getFrontmostEntry()
    @toggleEntry($entry)

  @nextEntry: ->
    ###
      Select the next entry if an active one exists, otherwise start navigation
      by making the closest entry to the user active
    ###
    $active = @$container.find('.active')
    if $active.length
      $entry = $active.prevAll('.entry:not(.year):first')
    else
      $entry = @getFrontmostEntry()
    @toggleEntry($entry)

  @toggleEntry: ($entry) ->
    ###
      Simulate a click on an entry
    ###
    $entry.find('.link:first').each(-> Timeline.toggleLink(this))

  @goTo: (slug, animate = true) ->
    ###
      Make its corresponding entry active and scroll to it, if the entry slug
      is not empty. Otherwise just remove any existent active state from any of
      the timeline's entries
    ###
    $entry = $(if slug then "#timeline-#{slug}" else null)
    if slug and $entry.length
      position = @getEntryPosition($entry)
    else
      position = $(window).scrollTop()
      # Subtract half the height of a currently expanded post's content (if
      # any and if it has one), because it's going to be untoggled and thus
      # hidden, in order to obtain better user experience and create the
      # sensation of going back to a previous position when untoggling an post
      $activeEntry = @$container.find('.post.active')
      if $activeEntry.find('.content').length
        # XXX see @getPostHeight to understand why we're now substracting the
        # height of the head instead of the content
        position -= $activeEntry.find('.head').outerHeight() / 2

    # The scrolling transition can be animated or instant, based on the
    # "animate" parameter
    @scrollTo(position, if animate then 0.2 else 0)
    @selectEntry($entry)
    @updatePageTitle($entry)
    @updatePageDescription($entry)

  @selectEntry: ($entry) ->
    ###
      Toggle the active state of timeline entries, while making sure that only
      one or no entries can be active at the same time
    ###
    # Remove active states from entries that are not targeted
    @$container.find('.entry').not($entry).contractEntry()
    # Make any targeted entry active (optional)
    $entry.expandEntry()

    # Mark entire timeline as having an active post when appropriate
    @$container.toggleClass('active-post', Boolean $entry.hasClass('post'))

    # The timeline header needs to be adjusted either when it becomes active or
    # when a different entry does, after it being previously active, and it
    # needs to go back in its default state in favour of that entry
    @adjustHeader()

  @scrollTo: (targetScroll, duration) ->
    # Get the current scroll position in order to make a transitioned movement
    startScroll = $(window).scrollTop()
    $(this).play
      time: duration
      onFrame: (ratio) =>
        # Get next scrolling position based on the current ratio of the
        # transition, offseting from the original scrolling point from where
        # the animation begun
        nextScroll = startScroll + ratio * (targetScroll - startScroll)
        # Get current window scroll and make sure it's still on track. If an
        # abnormal change has occured (i.e. a user scroll or a pop state event
        # firing because of back/forward browser actions), cancel the scroll
        # transition in order to avoid messing with the user's input and
        # causing an overall bad UX
        currentScroll = $(window).scrollTop()
        # XXX should be a way to cancel transition altogether if number is
        # off bounds
        if @numberInRange(currentScroll, [startScroll, nextScroll])
          $('html, body').scrollTop(nextScroll)

  @updatePageTitle: ($entry) ->
    # End all titles with the name of the timeline user
    title = @$container.find('h1').text()
    if $entry.hasClass('post')
      headline = $entry.find('h2').text()
      title = "#{headline} — #{title}"
    else if $entry.hasClass('year')
      year = $entry.find('.bullet').text()
      title = "#{year} — #{title}"
    else if $entry.hasClass('header')
      title = "Contact — #{title}"
    document.title = title

  @updatePageDescription: ($entry) ->
    # Set the page description to the profile bio, but default to the tagline
    # is bio text is left empty
    description = $.trim(@$container.find('.entry.header .text').text()) or
                  $.trim(@$container.find('.entry.header .head p').text())
    # Use the excerpt of a post as the meta description, when linking directly
    # to it (if one exists for that post)
    if $entry.hasClass('post')
      excerpt = $.trim($entry.find('.head p:first').text())
      description = excerpt if excerpt.length > 0
    # No point in updating the page description with an empty value
    if description
      $('meta[name=description]').prop('content', description)

  @toggleLink: (anchor) =>
    # Toggle link path if currently on it
    path = @getPathByTarget(anchor)
    if path is @getCurrentPath()
      path = @getDefaultPath()
    else
      # Track each opening of timeline entries in Mixpanel
      # XXX disable tracking timeline entries for now because they represent
      # over 80% of all user actions and hence cost most of the available
      # Mixpanel data points (https://mixpanel.com/pricing/)
      #mixpanel.track('timeline entry', path: path)
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

  @getFrontmostEntry: ->
    ###
      Get the entry most visible to the user (closest to the window center)
    ###
    # Calculate the offset to the center of the window viewport
    userOffset = $(window).scrollTop() + ($(window).height() / 2)

    # Start with the header entry and compare all entry offsets between them
    $entry = @$container.find('.entry.header')
    minOffset = Math.abs(userOffset - @getEntryOffset($entry))

    @$container.find('.entry.post').each (i, entry) =>
      offset = Math.abs(userOffset - @getEntryOffset($(entry)))
      if offset < minOffset
        $entry = $(entry)
        minOffset = offset

    return $entry

  @getEntryOffset: ($entry) ->
    ###
      Calculate the top offset of an entry based on the position of its bullet
    ###
    $bullet = $entry.find('.bullet')
    return $bullet.offset().top + ($bullet.height() / 2)

  @getEntryPosition: ($entry) ->
    position = $entry.offset().top

    # Subtract the height of a previously active post from the scroll
    # position (because it will be contracted), but only if the post precedes
    # the soon-to-be-active entry
    $activeEntry = $entry.prevAll('.post.active')
    if $activeEntry.length
      position -= @getPostContentHeight($activeEntry)

    if $entry.hasClass('post')
      height = @getPostHeight($entry)
    else
      height = $entry.height()

    # Get position of entry centered vertically, if its entire height is
    # smaller than the window viewport
    if height < $(window).height()
      position -= Math.round(($(window).height() - height) / 2)
    return position

  @getPostHeight: ($entry) ->
    ###
      Calculate height of entry as it would be when fully extended, because
      that's how it's going to be by the time we scroll to it
    ###
    height = $entry.find('.head').outerHeight()
    # XXX use the height of the entry head instead of its content in order to
    # align the entry on the middle, vertically, thus creating an effect where
    # the border between the entry head and content splits the screen by two,
    # horizontally
    if $entry.find('.content').length
      height += $entry.find('.head').outerHeight()
    return height

  @getPostContentHeight: ($entry) ->
    ###
      Calculate the exact height of an entry's content section. Unless it is
      missing, in which case it will be zero
    ###
    return 0 unless $entry.find('.content').length
    return $entry.find('.content .inner-wrap').outerHeight()

  @numberInRange: (number, range) ->
    range.push(number)
    # Sort all numbers ascending
    range.sort((a, b) -> a - b)
    # The subject should now be in the middle of the two range extremities
    return range[1] is number


# Extend jQuery bubble plugin in order to lock and unlock a bubble on demand
$.fn.lockBubble = ->
  @each ->
    bubble = $(this).data('bubble')
    if bubble
      bubble.toggle(1)
      bubble.unbind()

$.fn.unlockBubble = ->
  @each ->
    bubble = $(this).data('bubble')
    if bubble
      bubble.toggle(0)
      bubble.bind()


# jQuery helpers for expanding/contracting an entry
$.fn.expandEntry = ->
  @addClass('active')
   .find('.bullet').lockBubble()
  @find('.content').height(@find('.content .inner-wrap').outerHeight())

$.fn.contractEntry = ->
  @removeClass('active')
   .find('.bullet').unlockBubble()
  @find('.content').height(0)


Template.timeline.events
  'click .link': (e) ->
    e.preventDefault()
    # Stop events from bubbling up so they don't reach the timeline element,
    # which already listens to click events and will untoggle any active entry
    # when receiving one
    e.stopPropagation()
    Timeline.toggleLink(e.currentTarget)
  # Untoggle any active entry when clicking on the timeline background,
  # outside any entry link
  'click .entries': Timeline.untoggleActiveEntry
  'click .entry .content': (e) ->
    # Stop events from bubbling up so they don't reach the timeline element,
    # which already listens to click events and will untoggle any active entry
    # when receiving one
    e.stopPropagation()

Template.timeline.rendered = ->
  Timeline.rendered(@firstNode)

Template.timeline.destroyed = ->
  Timeline.destroyed(@firstNode)

Template.timeline.entries = ->
  # Get entries of current user only
  return Entry.getByYears(App.router.args.username)

Template.timeline.iconClass = (icon) ->
  return icon or 'icon-circle'

Template.timeline.parity = (index) ->
  return if index % 2 then 'odd' else 'even'
