#!/bin/bash

while [[ "$(pg_isready -h ${DB_HOST} -U ${DB_USERNAME})" =~ "no response" ]]; do
  echo "Waiting for postgresql to start..."
  sleep 1
done

if [ "${RACK_ENV}" == "production" ]; then
  /usr/bin/supervisord -c /app/config/docker/supervisord.conf
else
  /usr/bin/supervisord -c /app/config/docker/supervisord_dev.conf
fi
