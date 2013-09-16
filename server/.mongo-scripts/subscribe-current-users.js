// Make sure you don't subscribe people who already unsubscribed (this should
// never be called again anyway)
db.users.update({isSubscribed: {'$exists': false}},
                {'$set': {isSubscribed: true}},
                {multi: true});
