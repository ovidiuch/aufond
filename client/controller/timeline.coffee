class @Timeline

  @rendered: (container) ->
    @$container = $(container)
    @adjustHeader()
    @setupBubbles(12)
    # XXX create own class for carousels to manage all set of images
    # independently, including their preloading
    @setupImageCarousels()
    # Go to opened path directly (no animation)
    # XXX should wait until DOM is completely ready (fonts, etc.)
    @goTo(App.router.args.slug, false)

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
    $timeline = @$container.parent('.timeline')
    # XXX determine whether we are on mobile or desktop view
    onExpandedLayout = $(window).width() >= 1208
    if onExpandedLayout
      # XXX set it to half the timeline width and retract the width of the
      # timeline bar
      $wrapper.width(($timeline.width() - 8) / 2)
    else
      $wrapper.width($timeline.width())

    # Set the width of an image list as the sum of all of its images' widths,
    # but not smaller than the width of the wrapper mask
    width = 0
    $wrapper.find('img').each((i, img) -> width += $(img).width())
    $wrapper.find('ul').width(Math.max(width, $wrapper.width()))

    # XXX make sure the carousels of even entries (left-handed) start their
    # scrolling position from right to left
    if onExpandedLayout and $wrapper.closest('.entry').hasClass('even')
      $wrapper.find('.viewport').scrollLeft($wrapper.width())

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
      # Subtract half the height of a currently expanded entry's content (if
      # any and if it has one), because it's going to be untoggled and thus
      # hidden, in order to obtain better user experience and create the
      # sensation of going back to a previous position when untoggling an entry
      $activeEntry = @$container.find('.entry.active')
      if $activeEntry.find('.content').length
        # XXX see @getPostHeight to understand why we're now substracting the
        # height of the head instead of the content
        position -= $activeEntry.find('.head').outerHeight() / 2

    # The scrolling transition can be animated or instant, based on the
    # "animate" parameter
    @scrollTo(position, if animate then 0.2 else 0)
    @selectEntry($entry)

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

  @openLink: (e) =>
    e.preventDefault()
    # Stop events from bubbling up so they don't reach the timeline element,
    # which already listens to click events and will untoggle any active entry
    # when receiving one
    e.stopPropagation()
    # Toggle link path if currently on it
    path = @getPathByTarget(e.currentTarget)
    if path is @getCurrentPath()
      path = @getDefaultPath()
    App.router.navigate(path, trigger: true)

  @untoggleEntry: (e) =>
    ###
      Untoggle any active entry
    ###
    $(e.currentTarget).find('.entry.active .link:first').click()

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

  @getEntryPosition: ($entry) ->
    position = $entry.offset().top

    # Substract the height of a previously active entry from the scroll
    # position (because it will be contracted), but only if the previously
    # active element precedes the new one
    $activeEntry = $entry.prevAll('.entry.active')
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
      missing, in which case it will be zero, it needs to be calculated as the
      entire content height minus half the size of the entry bullet, under
      which the content element is folded
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
  'click .link': Timeline.openLink
  # Untoggle any active entry when clicking on the timeline background,
  # outside any entry link
  'click .entries': Timeline.untoggleEntry
  'click .entry .content': (e) ->
    # Stop events from bubbling up so they don't reach the timeline element,
    # which already listens to click events and will untoggle any active entry
    # when receiving one
    e.stopPropagation()

Template.timeline.rendered = ->
  Timeline.rendered(@firstNode)

Template.timeline.entries = ->
  # Get entries of current user only
  return Entry.getByYears(App.router.args.username)

Template.timeline.iconClass = (icon) ->
  return icon or 'icon-circle'

Template.timeline.parity = (index) ->
  return if index % 2 then 'odd' else 'even'


Meteor.startup ->
  $(window).resize ->
    Timeline.adjustImageCarousels()
