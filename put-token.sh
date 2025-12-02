if [ -f .env ]; then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

INPUT="created:$( date +%s%N | cut -b1-13 )"
RESULT=$(sign.sh $INPUT)
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo $RESULT
    exit $EXIT_CODE
fi

HEADER="Signature: ${RESULT}"
# HEADER="Signature: keyId:device_id,${INPUT},signature:wrong"
echo "Using header: $HEADER"

if [ -z "$DEVICE_TOKEN" ]; then
    echo "Error: DEVICE_TOKEN environment variable not set."
    exit 1
fi

# Store curl output and status code separately
RESPONSE=$(curl -s -X PUT -H "$HEADER" -H "Content-Type: application/json" -d '{"token":"'"$DEVICE_TOKEN"'"}' http://localhost:8080/realms/mfa/credential/registration-token)
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "$HEADER" -H "Content-Type: application/json" -d '{"token":"'"$DEVICE_TOKEN"'"}' http://localhost:8080/realms/mfa/credential/registration-token)

# Pretty print JSON response
echo "$RESPONSE" | jq .
echo "Status: $STATUS_CODE"
