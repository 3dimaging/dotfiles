#!/usr/bin/env bash

ED="emacs"
EC="emacsclient"
OPTS=""
SFDIR="$HOME/.emacs.d/server"
PORT="1"
HN=$(hostname -f)

if [[ -d "$HOME/.emacs.d/.local/cache/server" && ! -f "$SF" ]]; then
  SFDIR="$HOME/.emacs.d/.local/cache/server"
fi

# get the latest file which could be named, for example, server1234
SF="$SFDIR/$(ls -t $SFDIR | head -n1)"

[[ ! -f "$SF" ]] && echo "error: could not find server file at $SF" && exit 2

# check for emacsclient path, fallback to home directory
hash emacsclient 2>/dev/null || EC="$HOME/.local/bin/emacsclient"

# hack: if options contain --eval then don't parse args

if [[ $@ != *--eval* ]]; then
  # dev note: since we're using bash 'getopts' arguments MUST be before the filename provided
  while getopts ":h" opt; do
    case $opt in
      h)
        cat << EOF
usage: $0 options

This script calls emacsclient if the file $SF exists and the reverse port is open, else if it calls emacs

OPTIONS:
  -h      Show this message
  any other option will be passed to emacs or emacsclient
EOF
        exit 0
        ;;
      \?)
        OPTS="$OPTS -$OPTARG"
        ;;
    esac
  done

  # shift the optional flags provided before the filename out of the way
  shift $(( OPTIND-1 ))

  FN=$(readlink -f $1 2>/dev/null)
else
  FN=$@
fi

# if $FN is empty then this usually means a non-existent directory was provided
[[ -z $FN ]] && echo "error: check FN='$FN'" && exit 1

# if server/server file exists, then grep it for the port
[[ -r $SF ]] && PORT=$(egrep -o '127.0.0.1:([0-9]*)' $SF | sed 's/127.0.0.1://')

# check to see if port is open; apparently, ubuntu needs the -v flag
[[ -n $(netstat -ant | grep $PORT | grep 'LISTEN') || $HOME == /Users/$USER ]] && ED="$EC -f $SF"

# build the tramp filename or local filename also
[[ $HOME != /Users/$USER ]] && FN="/ssh:$(whoami)@$HN:$FN"

# fucking git
[[ "$FN" == *"mergetool-emacsclient"* && "$FN" == *"eval ("* ]] && FN=$(echo $FN | sed 's,",\\",g' | sed 's,eval (,eval "(,' | sed 's,"),")",')
$ECHO eval $ED $OPTS $FN
