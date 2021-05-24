#!/bin/bash

#sets DAY to Day of the week
DAY=$(date +%a)

#May Gets data of last full back up
Date=$(cat "$2/Date.txt")

#if File exsits t deleat it
if [ -e $2/incr/$DAY ] ; t
  rm -fr $2/incr/$DAY
fi

#rsync incremental daily backup
rsync -a --delete --quiet --inplace --backup --backup-dir="$2/incr/$DAY" "$2" "$2/$Date/"

#done