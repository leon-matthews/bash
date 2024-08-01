

function mr() {
    # Recursively find and play a random media file under the current folder.
    FILE=$(find . -regextype posix-egrep -type f \
        -iregex ".*(avi|mkv|mp3|mp4|mpg|mpeg|ogm|opus|wmv|wav)\$" | \
        shuf -n1 )
    if [ -z "$FILE" ]
    then
      echo "No media files found" >&2
      return 1
    fi
    ls -lh "$FILE"
    mpv -fs --audio-display=no "$FILE"
}


function mrr() {
    # Run mr in a loop. Try 'q' to skip to next song!
    while true;
    do
        mr || break
    done
}


# Filter output of 'ps -ef'
# eg. 'psgrep apache'
psgrep()
{
    ps -ef | grep $1 - | grep -v grep
}


# Delete python cruft
# '*.pyc', '*.pyo' files, and '__pycache__' directories
pyc() {
    find . -type f -name '*.py[co]' -delete \
        -or -type d -name '__pycache__' -delete \
        -or -type d -name '.mypy_cache' -delete
}


# Retry command on failure
function retry {
    local RETRIES=3
    local WAIT=2
    local ATTEMPT=0

    while [[ $ATTEMPT < $RETRIES ]]
    do
        set +e
        "$@"    # Run command
        EXIT_CODE=$?
        set -e
        if [[ $EXIT_CODE == 0 ]]
        then
            break
        fi

        echo "Command reported failure. Retrying in $WAIT seconds.." 1>&2
        sleep $WAIT

        ATTEMPT=$(( ATTEMPT + 1 ))
    done

    if [[ $EXIT_CODE != 0 ]]
    then
        echo "Command failed $RETRIES times, aborting: ($@)" 1>&2
    fi
}


# Rust Run and Run and Run
function rrun {
    while true
    do
        cargo run -q $@

        # Cargo returns error code 101 if not even in a project
        if [ $? -eq 101 ]; then
            break;
        fi

        # Build in some latency
        sleep 1

        # Block until some source file changes
        inotifywait -qq -e create,delete,modify,move -r src/;
        clear
    done
}
