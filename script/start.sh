#/bin/bash

port=3000

# The port can be specified as the first parameter
if [ "$1" ]
then
  port=$1
  echo "Setting app for port $port..."
fi

# Check if Meteor (node) app is still running
already_running=$(ps aux | grep "node .bundle/main.js" | grep -v "grep")
if [ "$already_running" ]
then
  # Extract process id from grepped process list
  process_id=$(echo $already_running | cut -d " " -f 2)
  # Carry on, but show an OK message
  echo "App already running [$process_id]"
else
  echo "Starting app..."
  # Check if this is ran from the project folder directly and go to it
  # otherwise
  in_app_folder=$(ls -a | grep ".bundle")
  if [ ! "$in_app_folder" ]
  then
    cd /var/www/aufond
    # Assume the script is called by the cron job and log that app was crashed
    # at that time
    echo "$(date) App was not running and had to be started" >> .log/crash
  fi

  # Start Aufond app with all required parameters
  PORT=$port \
  MONGO_URL=mongodb://aufond:aufond.mongodb@dharma.mongohq.com:10042/aufond \
  ROOT_URL=http://aufond.me:$port \
  nohup node .bundle/main.js > .log/output &
fi
