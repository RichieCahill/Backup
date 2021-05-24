#!/bin/bash

#sets Date
Date=$(date +%F)

#rsunt selected files
rsync -a --delete --quiet "$1" "$2/$Date"

#Creats most resent backup date file
echo "$Date" > "$Backup/Date.txt"