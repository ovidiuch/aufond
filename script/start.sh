#/bin/bash

port=3000

# The port can be specified as the first parameter
if [ "$1" ]
then
  port=$1
fi

PORT=$port MONGO_URL=mongodb://aufond:aufond.mongodb@dharma.mongohq.com:10042/aufond \
ROOT_URL=http://aufond.me:$port \
node bundle/main.js
