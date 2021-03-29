#!/bin/bash

#sets the date
Date=$(date +%F)

#Runs rsync arter rsync runs msgs discord
if [[ $(rsync -a --delete "$1" "$2/$Date") -eq 0 ]]; then
  message="Success"
else
  message="@everyone Fail $?"
fi

## format to parse to curl
## echo Sending message: $message
msg_content=\"$message\"

## discord webhook
url=''
curl -H "Content-Type: application/json" -X POST -d "{\"content\": $msg_content}" $url

#Creats most resent backup date file
echo "$Date" > "$2/Date.txt"
