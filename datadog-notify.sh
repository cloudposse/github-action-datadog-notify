#!/bin/bash
##
##  MIT License
##
##  Copyright (c) 2022 Developer Mountain and Adam Whittingham
##  Copyright (c) 2022 Cloud Posse, LLC <maintainers@cloudposse.com>
##  The following code is a derivative work of the code from https://github.com/dvmtn/datadog-notify,
##  which is licensed MIT. This code is also licensed under the terms of the MIT License.

function usage(){
  echo "Usage:" >&2
  echo "$0 title message [error|warning|info|success] [tags...]" >&2
  echo "  title:   The title of this event            ie. 'Foo Restated'" >&2
  echo "  message: The message for this event         ie. 'Foo was restarted by monit'" >&2
  echo "  type:    The event type, one of 'info', 'error', 'warning' or 'success'" >&2
  echo "  tags:    Optional tags in key:vaule format  ie. 'app:foo group:bar" >&2
  echo >&2
  echo "Examples:" >&2
  echo "$0 'Test Event' 'This event is just for testing' info 'test:true foo:bar'" >&2
  echo "$0 'Another Event' 'This event is just for testing'" >&2
  exit 1
}

title="$1"
message="$2"
alert_type="$3"


if [[ -z "$DATADOG_API_KEY" ]]; then
  echo "Could not find Datadog API key in the DATADOG_API_KEY environment variable." >&2
  echo "Please provide your API key in one of these locations" >&2
  usage
fi

if [[ -z "$title" || -z "$message" ]]; then
  usage
fi

if [[ -z "$alert_type" ]]; then
  echo "No level set, assuming 'info'" >&2
  alert_type='info'
fi

if $(echo "$alert_type" | grep -qv 'error\|warning\|info\|success\|user_update\|recommendation\|snapshot' ); then
  echo "Failed: alert_type was '$alert_type', needs to be one of 'success', 'info', 'error', 'warning', 'user_update', 'recommendation', or 'snapshot'" >&2
  echo >&2
  usage
fi

if [[ ${APPEND_HOSTNAME_TAG} ]]; then
  tag="${APPEND_HOSTNAME_TAG}:$(hostname) $4"
else
  tag="$4"
fi
tags=$(echo $tag | sed -e's/[\.a-zA-Z:0-9\/\_\-]*/\"&\"/g' -e's/\" \"/\", \"/g' )

api="https://app.datadoghq.com/api/v1"
datadog="${api}/events"

payload=$(cat <<-EOJ
  {
    "title": "$title",
    "text": "$message",
    "tags": [$tags],
    "alert_type": "$alert_type"
  }
EOJ
)

#echo -e "$payload"

response=$(curl -s -X POST -H "Content-type: application/json" -H "DD-API-KEY: ${DATADOG_API_KEY}" -d "$(echo "${payload}" | sed ':a;N;$!ba;s/\n/ /g')" "$datadog")

if [[ $(echo "$response" | grep -c '"status":"ok"') -eq 1 ]]; then
  echo "Success: Event sent to Datadog" >&2
  exit 0
else
  echo "Failed: Event not sent to Datadog" >&2
  echo "Response: $response" >&2
  exit 1
fi
