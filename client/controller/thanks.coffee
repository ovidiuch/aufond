Template.thanks.events
  'click .link-home': (e) ->
    e.preventDefault()
    App.router.navigate('', {trigger: true, resetScroll: true})

  'click .link-admin-exports': (e) ->
    e.preventDefault()
    App.router.navigate('admin/exports', {trigger: true, resetScroll: true})

Template.thanks.ideaForm = ->
  module: IdeaForm
  model: 'SurveySuggestion'

quizQuestions =
  "More types of media besides text and images":
    yes: 143
    no: 81
    total: 224
    ratio: 0.6383928571428571
    percentage: "63.84"
    aboveRatio: 0
    abovePercentage: "0.00"
    relativeRatio: 0
    relativePercentage: "0.00"
  "A more customizable layout or styling":
    yes: 157
    no: 66
    total: 223
    ratio: 0.7040358744394619
    percentage: "70.40"
    aboveRatio: 0.06564301729660482
    abovePercentage: "6.56"
    relativeRatio: 0.24450793270179763
    relativePercentage: "24.45"
  "Making the navigation more obvious":
    yes: 138
    no: 58
    total: 196
    ratio: 0.7040816326530612
    percentage: "70.41"
    aboveRatio: 0.06568877551020413
    abovePercentage: "6.57"
    relativeRatio:  0.2446783734687225
    relativePercentage: "24.47"
  "Importing content from external platforms":
    yes: 133
    no: 62
    total: 195
    ratio: 0.6820512820512821
    percentage: "68.21"
    aboveRatio: 0.043658424908424975
    abovePercentage: "4.37"
    relativeRatio:  0.16261944771889364
    relativePercentage: "16.26"
  "Offline exporting options":
    yes: 174
    no: 31
    total: 205
    ratio: 0.848780487804878
    percentage: "84.88"
    aboveRatio: 0.21038763066202093
    abovePercentage: "21.04"
    relativeRatio:  0.783654480822604
    relativePercentage: "78.37"
  "Maintaining and refining the current simplicity":
    yes: 185
    no: 19
    total: 204
    ratio: 0.9068627450980392
    percentage: "90.69"
    aboveRatio: 0.2684698879551821
    abovePercentage: "26.85"
    relativeRatio: 1
    relativePercentage: "100.00"

for k, v of quizQuestions
  v.showAbovePercentage = v.relativeRatio > 0
  v.smallAbovePercentage = v.relativeRatio < 0.5
  # XXX the reversed percentage is used to create a masking effect in progress
  # bars, when the below and above layers share common labels
  reversedRatio = if v.relativeRatio then 1 / v.relativeRatio else 0
  v.reversedPercentage = (reversedRatio * 100).toFixed(2)

# Turn questions into an array in order to be easily iterable in the template
Template.thanks.questions = (_.extend(question: k, v) for k, v of quizQuestions)
Template.thanks.sortedQuestions =
  _.sortBy(Template.thanks.questions, (question) -> question.ratio)

###
  Export animation
###
exportAnimationInterval = null
exportAnimationSlide = ($slides) ->
  ###
    Always pick up the first DOM element and move it to the end of the list, in
    order to create a continuous animation
  ###
  $nextSlide = $slides.first()
  $nextSlide.hide()
  $nextSlide.parent().append($nextSlide)
  $nextSlide.fadeIn(400)

Template.thanks.rendered = ->
  return if exportAnimationInterval?
  goToNextSlide = =>
    # Always query the slide children from the DOM, to get them in the current
    # order they are positioned (since it changes with every interval loop)
    exportAnimationSlide($(@find('.export-animation')).children())
  # Make one initial instant call to start with the first slide
  goToNextSlide()
  exportAnimationInterval = setInterval(goToNextSlide, 2000)
  # Setup bubble hover for exhibited users
  $(@find('.happy-campers')).find('a').bubble
    time: 0.1
    offset: 8

Template.thanks.destroyed = ->
  if exportAnimationInterval?
    clearInterval(exportAnimationInterval)
    exportAnimationInterval = null
