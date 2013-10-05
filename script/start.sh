#/bin/bash

hostname="localhost"
port=80
mongo_url="mongodb://guest:aufond1234@paulo.mongohq.com:10016/aufond_guest"

# Allow hostname, port and mongo url to be overriden through params
while getopts ":h:p:m:" opt; do
  case $opt in
    h)
      hostname=${OPTARG}
      ;;
    p)
      port=${OPTARG}
      ;;
    m)
      mongo_url=${OPTARG}
      ;;
  esac
done

# Only append port to hostname if different than 80
if [ $port != 80 ]
then
  hostname+=":$port"
fi

# Check if a process is already running on the requested port
already_running=$(lsof -i :$port | grep LISTEN)
if [ "$already_running" ]
then
  # Extract and output process id from grepped process list
  process_id=$(echo $already_running | cut -d " " -f 2)
  echo "App already running [$process_id]"
else
  # Check if this is ran from the project folder directly and fail otherwise
  in_app_folder=$(ls -a | grep ".bundle")
  if [ ! "$in_app_folder" ]
  then
    echo "Please run the start script from the root folder of the project!"
    exit 1
  fi

  # Get property formatted UTC time (in a way that an alphabetical sort results
  # in a chronological order)
  utc_time="$(env TZ=UTC date +%Y-%m-%d-%H:%M:%S)"

  # Log whenever we start the app (useful for when it crashes and is started
  # automatically from a cronjob)
  echo "$utc_time App started on port $port" >> .log/start

  # Create an unique output log for each process, helps post-crash debugging
  output_log=".log/output-$utc_time"

  # Start aufond app with all required parameters
  echo "Starting app on $hostname..."
  export PORT=$port
  export MONGO_URL=$mongo_url
  export ROOT_URL=http://$hostname
  export METEOR_SETTINGS=$(cat ./settings.json)
  nohup /usr/local/bin/node .bundle/main.js >> $output_log 2>> $output_log &
fi
