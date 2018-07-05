#!/bin/bash

# required env GET_INSTANCES: command to return a list of instances
# required env SRC: path to jinja2 template
# required env TARGET: path to save output
# optional env CONTAINER_NAME: container to send HUP to, if set

get_data() {
  echo instances:
  for instance in $( eval $GET_INSTANCES ); do
    echo -n "  - "
    gcloud compute instances describe $instance --format=json | jq -c .
  done
}

tmpfile=$(mktemp -d)/data.yml

hash=''

while true; do

  get_data > $tmpfile

  yasha -v $tmpfile -o $TARGET $SRC

  if [ -n "$CONTAINER_NAME" ]; then

    oldhash=$hash
    hash=$(md5sum $TARGET | cut -d ' ' -f 1)

    if [ "$hash" != "$oldhash" ]; then
      echo sending HUP to $CONTAINER_NAME
      docker kill -s HUP $CONTAINER_NAME
    fi
  fi

  sleep 60s

done
