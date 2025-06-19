#!/bin/bash

configDir="/etc/filewatcher"

# Make sure that the config directory exists.
mkdir -p "$configDir"
if [ $? -ne 0 ]; then
    echo "Error creating directory: $configDir" >&2
    # Handle the error (e.g., exit, log, or provide a fallback)
    exit 1
fi


# Read any defaults if they exist
DEFAULT_FILE="$configDir/default.conf"
if [ -f "$DEFAULT_FILE" ]; then
    source $DEFAULT_FILE
fi


# Read the config file if it exists
CONFIG_FILE="$configDir/$1.conf"
if [ -f "$CONFIG_FILE" ]; then
    source $CONFIG_FILE
fi



# If they are not set, we'll exit with an error
if [ -z "$FILE_TO_WATCH" ] || [ -z "$SCRIPT_TO_RUN" ]; then
    echo "Error: FILE_TO_WATCH and SCRIPT_TO_RUN must be set in the config file."
    echo "Config Directory: $configDir"
    exit 1
fi


# If the script to run is not found, we'll exit with an error
if [ -z "$SCRIPT_TO_RUN" ]; then
    echo "Error: The Target Script was not Found:"
    echo "    $SCRIPT_TO_RUN"
    exit 1
fi


# If the script working directory is not set, we'll use the directory of the script
if [ -z "$SCRIPT_WORKING_DIR" ]; then
    SCRIPT_WORKING_DIR=$(dirname "$SCRIPT_TO_RUN")
fi

# Function to execute the script
execute_script() {

    # If the file changes while we are running the script, we'll need to
    # run the script again.  We'll check this by hashing the file before 
    # and after each of the script executions.
    FINAL_HASH=$(sha256sum "$FILE_TO_WATCH" | awk '{ print $1 }')
    RUN_COUNT=0
    while [ "$INITIAL_HASH" != "$FINAL_HASH" ]; do
        INITIAL_HASH=$FINAL_HASH

        # Execute the script:
        RUN_COUNT=$((RUN_COUNT + 1))
        echo "$INITIAL_HASH - [$RUN_COUNT]: $SCRIPT_TO_RUN"
        $SCRIPT_TO_RUN

        FINAL_HASH=$(sha256sum "$FILE_TO_WATCH" | awk '{ print $1 }')
    done
}

# Function to handle SIGTERM
handle_sigterm() {
    echo "Received SIGTERM signal. Exiting..."
    exit 0
}

# Set up the trap for SIGTERM
trap handle_sigterm SIGTERM


# Check if the inotifywait command is available
if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotifywait is not installed. Please install inotify-tools."
    exit 1
fi

# Chante to the working directory of the script:
cd $SCRIPT_WORKING_DIR

# If we are set up to execute the script on start, we'll do so now.
if [ "$EXEC_ON_START" == "true" ]; then
    execute_script
fi  

# Main Loop.  We'll do this until we are killed by the user or the system.
echo "Starting File Watcher for $FILE_TO_WATCH"
while true; do

    # If the file doesn't exist, we've nothing to do
    if [ ! -e "$FILE_TO_WATCH" ]; then
        sleep 1
        continue
    fi

    # We'll start monitoring our file.  Generally speaking, a close_write
    # means that a record has been added to the file while a delete_self
    # means that the file has been deleted and rewritten in order to remove 
    # a line.
    inotifywait -t 5 -q -e delete_self,close_write "$FILE_TO_WATCH" |
    while read -r filename events; do
        echo "Event: $events for $filename"

        # Execute our configured script:
        execute_script

        # If the file was deleted, we need to break out of the loop because 
        # our file montior has been borken.  We need to restablish it.
        if [[ "$events" == *"DELETE_SELF"* ]]; then
            break
        fi
    done
done
