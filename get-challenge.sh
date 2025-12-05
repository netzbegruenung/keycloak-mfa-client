#!/bin/bash

BASE_URL=${1:-"http://localhost:8080/realms/mfa"}

INPUT="created:$( date +%s%N | cut -b1-13 )"
RESULT=$(./sign.sh $INPUT)
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo $RESULT
    exit $EXIT_CODE
fi

HEADER="Signature: $RESULT"

# Store curl output and status code separately
RESPONSE=$(curl -s -H "$HEADER" "${BASE_URL}/challenges")
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "$HEADER" "${BASE_URL}/challenges")

# Pretty print JSON response
echo "$RESPONSE" | jq .
echo "Status: $STATUS_CODE"
