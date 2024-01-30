#!/bin/bash

# Paths of files relative to root since scripts are to be invoked from Makefile
ENV_FILE=".env"
COMMANDS_FILE="./scripts/commands"

# Load environment variables from .env file
if [ -f $ENV_FILE ]; then
  export $(grep -v '^#' $ENV_FILE | xargs)
fi

# Read the commands from the file and format as JSON
COMMANDS_JSON=$(awk '{print "{\"command\":\"" $1 "\", \"description\":\"" substr($0, index($0,$2)) "\"}"}' $COMMANDS_FILE | paste -sd, -)

# Make the curl call to set the commands
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/setMyCommands" \
     -H "Content-Type: application/json" \
     -d "{\"commands\":[$COMMANDS_JSON]}"
