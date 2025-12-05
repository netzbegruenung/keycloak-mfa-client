#!/bin/bash

# Defaults
GRANTED="true"
BASE_URL="http://localhost:8080/realms/mfa"

# Argument parsing for [granted] and [base_url]
# Usage: $0 [true|false] [base_url]
if [[ "$1" == "true" || "$1" == "false" ]]; then
  GRANTED=$1
  if [ -n "$2" ]; then
    BASE_URL=$2
  fi
elif [ -n "$1" ]; then
  BASE_URL=$1
fi

# Step 1: Fetch the latest challenge
echo "Fetching challenge from ${BASE_URL}..."
CHALLENGE_RESPONSE=$(./get-challenge.sh "${BASE_URL}")
CHALLENGE_STATUS_CODE=$(echo "$CHALLENGE_RESPONSE" | tail -n1 | awk '{print $2}')

# Check if challenge was fetched successfully
if [ "$CHALLENGE_STATUS_CODE" -ne 200 ]; then
    echo "Error fetching challenge:"
    echo "$CHALLENGE_RESPONSE"
    exit 1
fi

# Extract the main JSON body (remove the status line)
CHALLENGE_JSON=$(echo "$CHALLENGE_RESPONSE" | sed '$d')

# Step 2: Extract targetUrl and codeChallenge from the response
TARGET_URL=$(echo "$CHALLENGE_JSON" | jq -r '.[0].targetUrl')
SECRET=$(echo "$CHALLENGE_JSON" | jq -r '.[0].codeChallenge')

if [ -z "$TARGET_URL" ] || [ "$TARGET_URL" == "null" ]; then
    echo "Error: Could not extract targetUrl from challenge response."
    exit 1
fi

if [ -z "$SECRET" ] || [ "$SECRET" == "null" ]; then
    echo "Error: Could not extract codeChallenge (secret) from challenge response."
    exit 1
fi

# Step 3: Create the components for the signature
CREATED_TIMESTAMP=$(date +%s%N | cut -b1-13)
DATA_TO_SIGN="created:${CREATED_TIMESTAMP},secret:${SECRET},granted:${GRANTED}"

# Step 4: Get the signature components from sign.sh
# sign.sh is expected to return the full string for the header, including the signature
SIGNATURE_DATA=$(./sign.sh "${DATA_TO_SIGN}")
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error signing the string."
    echo "${SIGNATURE_DATA}"
    exit $EXIT_CODE
fi

# Step 5: Construct the Signature header
HEADER="Signature: ${SIGNATURE_DATA}"
echo "Using header: $HEADER"

# Step 6: Send the GET request to the targetUrl
echo "Sending request to $TARGET_URL"
# Get response body and status code in one call
RESPONSE_WITH_STATUS=$(curl -s -w "\\n%{http_code}" -H "$HEADER" "$TARGET_URL")
STATUS_CODE=$(echo "$RESPONSE_WITH_STATUS" | tail -n1)
RESPONSE=$(echo "$RESPONSE_WITH_STATUS" | sed '$d')

# Pretty print JSON response
echo "$RESPONSE" | jq .
echo "Status: $STATUS_CODE"
