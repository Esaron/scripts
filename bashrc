#!/bin/bash

#
# Lots of bash utility functions
#

# Utility to join an array with a given separator
# example usage:
#    `join | A B C`
#    will print "A|B|C"
function join {
  IFS=$1
  shift
  echo "$*"
}

# read a paths file, new-line spearated list of locations and return a PATH string
# will resolve $HOME and other tokens
# example usage:
#   export PATH="$(join ":" $PATH ~/bin $(readpaths ~/bin/paths))"
function readpaths {
  local IFS
  local pathfile=$1
  local LINES
  IFS=$'\n' read -d '' -r -a LINES < <( sed '/^\#/d' $pathfile )
  IFS=":"
  eval echo "${LINES[*]}"
}

#
# Method which builds up a path-like string of the arguments and their children (sorted ignoring case)
# @param dirs... a list of directories
#
function createChildDirsPath {
        local ELEMENT
        for ELEMENT in $( find "$@" -depth -type d -or -type l | sort --ignore-case );
        do
                [ -h "$ELEMENT" ] && ELEMENT=`readlink "$ELEMENT"` # resolve single layer of links
                [ -d "$ELEMENT" ] && RESULT="$RESULT":"$ELEMENT" # add directories to RESULT
        done;
        echo "${RESULT##:}"
}

# test if the current shell is interactive, returns 0 if interative, 1 otherwise
# can be used like `if [ $(isInteractive) ]; ...`
function isInteractive {
   if [[ "$-" == *i* ]]
   then
     return 0
   fi
   return 1
}

# set key bindings so up and down to search based history completion
function setup_key_bindings {
if $( isInteractive )
    then
        bind '"\e[A":history-search-backward'
        bind '"\e[B":history-search-forward'
        #bind '"\t":menu-complete' # cycle through matches on repeated tab
    fi
}
setup_key_bindings

#
# Example Setup
#

#umask u=rwx,g=rx,o=
#export GREP_OPTIONS="--color --directories=skip" # colorize grep output, and silently skip directories

export EDITOR=vim
export GIT_EDITOR=vim
export ANT_OPTS=-Xmx512m

source ~/.bash/colors
source ~/.bash/symbols
source ~/.bash/gitprompt

# use git based PS1
setup_git_ps1
setup_git_promptcommand

# ll lists files with type, human size, and columns
alias ll="ls -CFhl"
