#!/bin/bash

# Paths of files relative to root since scripts are to be invoked from Makefile
ENV_FILE=".env"

# Load environment variables from .env file
if [ -f $ENV_FILE ]; then
  export $(grep -v '^#' $ENV_FILE | xargs)
fi

# Retrieve the ngrok URL
NGROK_TUNNELS=$(curl --silent http://127.0.0.1:4040/api/tunnels)
NGROK_URL=$(echo $NGROK_TUNNELS | grep -o '"public_url":"[^"]*' | grep -o 'http[^"]*')

# Check if the URL was retrieved successfully
if [[ $NGROK_URL == http* ]]; then
  # Post jobs.json to the ngrok URL
  POST_RESPONSE=$(curl -X POST -H "Content-Type: application/json" -d @./packages/jobstash_api/jobs.json  "$NGROK_URL/jobs")
  echo "Posted jobs.json to $NGROK_URL/jobs"
  echo "Response: $POST_RESPONSE"
else
  echo "Failed to retrieve ngrok URL."
fi