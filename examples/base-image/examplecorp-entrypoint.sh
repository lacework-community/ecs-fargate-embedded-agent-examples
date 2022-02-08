#!/bin/sh
# Minimal datacollector sidecar start script
#
# Environment Variables:
# LaceworkAccessToken="..."      (Required)
# LaceworkDebug="true"           (Optional, will tail datacollector.log)

# Check for Access Token
if [ -z "$LaceworkAccessToken" ]; then
  echo "Please set the LaceworkAccessToken environment variable"
  exit 1
fi

# Create config file
echo "Writing Lacework datacollector config file to /var/lib/lacework/config/config.json"
LW_CONFIG="{\"tokens\": {\"accesstoken\": \"${LaceworkAccessToken}\"}}"
echo $LW_CONFIG > /var/lib/lacework/config/config.json

# Optional debug logging
if [ "$LaceworkDebug" = "true" ]; then
  echo "Debug mode: tailing /var/log/lacework/datacollector.log"
  touch /var/log/lacework/datacollector.log
  tail -f /var/log/lacework/datacollector.log &
fi

# Start datacollector
/var/lib/lacework/datacollector &
echo "Lacework datacollector started"

# Run Docker CMD
exec "$@"
