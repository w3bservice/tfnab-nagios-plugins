#!/bin/bash

# Plugin Name: check_svnstatus
# Version: 0.2
# Author: Martin Lormes
# Author URI: http://ten-fingers-and-a-brain.com

# Copyright (c) 2011-2012 Martin Lormes
#
# This program is free software; you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation; either version 3 of the License, or (at your option) any later 
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with 
# this program. If not, see <http://www.gnu.org/licenses/>.

### parsing and help message

usage="Usage: `basename $0` -d directory [ -v ]"

if [ $# -eq 0 ]
then
  echo >&2 $usage; exit 3;
fi

while [ $# -gt 0 ]
do
  case "$1" in
    -d)
      directory="$2"
      shift
      if [ $# -eq 0 ]
      then
        echo >&2 "`basename $0`: missing argument"; exit 3;
      fi
      ;;
    -v)
      verbose="1"
      ;;
    *)
      echo >&2 $usage
      exit 3
      ;;
  esac
  shift
done

### get working copy status and return service state

OUT1=`svn status $directory | egrep -v ^$\|^Performing\ status\ on\ external\ item\ at\|^X`
OUT2=$(svn status $directory 2>&1 1>/dev/null)

if [ -n "$OUT2" ]
then
  echo "UNKNOWN: $OUT2"
  exit 3
else
  if [ -n "$OUT1" ]
  then
    echo "CRITICAL: working copy at $directory contains modifications"
    if [ $verbose ]
    then
      echo "$OUT1"
    fi
    exit 2
  else
    echo "OK: working copy at $directory is unmodified"
    exit 0
  fi
fi

