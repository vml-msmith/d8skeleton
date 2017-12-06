#!/bin/bash

# Author: Tasos Latsas

# spinner.sh
#
# Display an awesome 'spinner' while running your long shell commands
#
# Do *NOT* call _spinner function directly.
# Use {start,stop}_spinner wrapper functions

# usage:
#   1. source this script in your's
#   2. start the spinner:
#       start_spinner [display-message-here]
#   3. run your command
#   4. stop the spinner:
#       stop_spinner [your command's exit status]
#
# Also see: test.sh


function _spinner() {
  # $1 start/stop
  #
  # on start: $2 display message
  # on stop : $2 spinner function pid (supplied from stop_spinner)

  local on_success="DONE"
  local on_fail="FAIL"

  case $1 in
    start)
      # calculate the column where spinner and status msg will be displayed
      let column=$(tput cols)-${#2}-8
      # display message and position the cursor in $column column
      echo -ne ${2}
      printf "%${column}s"

      # start spinner
      i=1
      sp='\|/-'
      delay=${SPINNER_DELAY:-0.1}

      while :
      do
        printf "\b${sp:i++%${#sp}:1}"
        sleep $delay
      done
      ;;
    stop)
      if [[ -z ${2} ]]; then
        echo "spinner is not running.."
        exit 1
      fi

      kill $2> /dev/null 2>&1

      echo -e "\b[${GREEN}DONE${NC}]"
      ;;
    *)
      echo "invalid argument, try {start/stop}"
      exit 1
      ;;
  esac
}

function start_spinner {
  # $1 : msg to display
  
  if [ $QUIET == 0 ]; then
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
  fi
}

function stop_spinner {
  if [ $QUIET == 0 ]; then
    # $1 : command exit status
    _spinner "stop" $_sp_pid
    unset _sp_pid
  fi
}
