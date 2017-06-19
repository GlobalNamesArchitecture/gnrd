#!/bin/bash
set -euo pipefail

while [[ "$(pg_isready -h ${GNRD_DB_HOST} -U ${GNRD_DB_USER})" =~ "no response" ]]; do
  echo "Waiting for postgresql to start..."
  echo ${GNRD_DB_HOST} 
  echo ${GNRD_DB_USER}
  sleep 1
done

erb /app/config/config.json.example > /app/config/config.json
rake db:create
rake db:migrate

if [ "$RACK_ENV" == "production" ]; then
  /usr/bin/supervisord -c /app/config/docker/supervisord.conf
else
  /usr/bin/supervisord -c /app/config/docker/supervisord_dev.conf
fi
