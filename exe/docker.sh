#!/bin/bash

if [ "$RACK_ENV" == "production" ]; then
  /usr/bin/supervisord -c /app/config/docker/supervisord.conf
else
  /usr/bin/supervisord -c /app/config/docker/supervisord_dev.conf
fi
