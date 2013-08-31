var getUniqueVotes = function(votes) {
  var uniqueVotes = [], hasNewerVote;
  votes.forEach(function(vote) {
    hasNewerVote = false;
    uniqueVotes.forEach(function(existingVote) {
      if (vote.question == existingVote.question &&
          vote.createdByGuestId == existingVote.createdByGuestId) {
        hasNewerVote = true;
      }
    });
    if (!hasNewerVote) {
      uniqueVotes.push(vote);
    }
  });
  return uniqueVotes;
};

var getVoteCountsForQuestion = function(votes, question) {
  var counts = {
    yes: 0, no: 0
  };
  votes.forEach(function(vote) {
    if (vote.question != question) {
      return;
    }
    if (vote.vote) {
      counts.yes++;
    } else {
      counts.no++;
    }
    // Decorate counts
    counts.total = counts.yes + counts.no;
    counts.ratio = counts.yes / counts.total;
    counts.percentage = (counts.ratio * 100).toFixed(2);
  });
  return counts;
};

// START //////////////////////////////////////////////////////////////////////

var mainQuestion = "Is this something you want?";
var quizQuestions = [
  "More types of media besides text and images",
  "A more customizable layout or styling",
  "Making the navigation more obvious",
  "Importing content from external platforms",
  "Offline exporting options",
  "Maintaining and refining the current simplicity"
];

// Take the most recent vote under consideration
var totalVotes = db.quizVotes.find().sort({createdAt: -1}).toArray();
// Because a question can be voted more than once by switching between the
// possible yes/no answers, we only need to select the last vote for a question
// by a certain guestId
var uniqueVotes = getUniqueVotes(totalVotes);

var counts = {
  totalVotes: totalVotes.length,
  uniqueVotes: uniqueVotes.length,
  uniqueVoters: db.quizVotes.distinct('createdByGuestId').length
};
printjson(counts);

// An object with the "yes" and "no" keys will be created for each questions,
// with each containing the counter of corresponding votes for that response
var quizResults = {};
[mainQuestion].concat(quizQuestions).forEach(function(question) {
  quizResults[question] = getVoteCountsForQuestion(uniqueVotes, question);
});

// Since vote ratios are pretty close, to see scale the actual difference
// between them we'll calculate them between the min and the max
var minRatio = 1;
var maxRatio = 0;
for (var i in quizResults) {
  minRatio = Math.min(minRatio, quizResults[i].ratio);
  maxRatio = Math.max(maxRatio, quizResults[i].ratio);
}
var difRatio = maxRatio - minRatio;
for (var i in quizResults) {
  quizResults[i].aboveRatio = quizResults[i].ratio - minRatio;
  quizResults[i].abovePercentage =
    (quizResults[i].aboveRatio * 100).toFixed(2);
  quizResults[i].relativeRatio = quizResults[i].aboveRatio / difRatio;
  quizResults[i].relativePercentage =
    (quizResults[i].relativeRatio * 100).toFixed(2);
}
printjson(quizResults);
