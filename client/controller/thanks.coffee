Template.thanks.events
  'click .link-home': (e) ->
    e.preventDefault()
    App.router.navigate('', trigger: true)

quizQuestions =
  "More types of media besides text and images":
    yes: 143
    no: 81
    total: 224
    ratio: 0.6383928571428571
    percentage: "63.84"
    relativeRati: 0
    relativePercentage: "0.00"
  "A more customizable layout or styling":
    yes: 157
    no: 66
    total: 223
    ratio: 0.7040358744394619
    percentage: "70.40"
    relativeRatio: 0.24450793270179763
    relativePercentage: "24.45"
  "Making the navigation more obvious":
    yes: 138
    no: 58
    total: 196
    ratio: 0.7040816326530612
    percentage: "70.41"
    relativeRatio:  0.2446783734687225
    relativePercentage: "24.47"
  "Importing content from external platforms":
    yes: 133
    no: 62
    total: 195
    ratio: 0.6820512820512821
    percentage: "68.21"
    relativeRatio:  0.16261944771889364
    relativePercentage: "16.26"
  "Offline exporting options":
    yes: 174
    no: 31
    total: 205
    ratio: 0.848780487804878
    percentage: "84.88"
    relativeRatio:  0.783654480822604
    relativePercentage: "78.37"
  "Maintaining and refining the current simplicity":
    yes: 185
    no: 19
    total: 204
    ratio: 0.9068627450980392
    percentage: "90.69"
    relativeRati: 1
    relativePercentage: "100.00"

# Turn questions into an array in order to be easily iterable in the template
Template.thanks.questions = (_.extend(question: k, v) for k, v of quizQuestions)
