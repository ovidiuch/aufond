#/bin/bash

port=80

# The port can be specified as the first parameter
if [ "$1" ]
then
  port=$1
  echo "Setting app for port $port..."
fi

# Check if a process is already running on the requested port
already_running=$(lsof -i :$port | grep LISTEN)
if [ "$already_running" ]
then
  # Extract and output process id from grepped process list
  process_id=$(echo $already_running | cut -d " " -f 2)
  echo "App already running [$process_id]"
else
  # Check if this is ran from the project folder directly and go to it
  # otherwise
  in_app_folder=$(ls -a | grep ".bundle")
  if [ ! "$in_app_folder" ]
  then
    cd /var/www/aufond
  fi

  # Make sure .log folder exists
  if [ ! -d ".log" ]
  then
    echo "Creating .log folder..."
    mkdir .log
  fi

  # Get property formatted UTC time (in a way that an alphabetical sort results
  # in a chronological order)
  utc_time="$(env TZ=UTC date +%Y-%m-%d-%H:%M:%S)"

  # Log whenever we start the app (useful for when it crashes and is started
  # automatically from a cronjob)
  echo "$utc_time App started on port $port" >> .log/start

  # Start aufond app with all required parameters
  echo "Starting app..."
  PORT=$port \
  MONGO_URL=mongodb://aufond:aufond.mongodb@dharma.mongohq.com:10042/aufond \
  ROOT_URL=http://aufond.me:$port \
  nohup /usr/local/bin/node .bundle/main.js > .log/output 2> .log/output &
fi
