#!/bin/sh

if [ "$1" == "production" ]; then
  export RACK_ENV=production
  /usr/bin/supervisor -c /app/config/docker/supervisor.conf
else
  /usr/bin/supervisor -c /app/config/docker/supervisor_dev.conf
fi
