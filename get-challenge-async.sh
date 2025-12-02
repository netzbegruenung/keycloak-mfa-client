INPUT="created:$( date +%s%N | cut -b1-13 )"
RESULT=$(sign.sh $INPUT)
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo $RESULT
    exit $EXIT_CODE
fi

HEADER="Signature: $RESULT"

curl -H "$HEADER" -w "\nStatus: %{http_code}" http://localhost:8080/realms/mfa/challenges/async

echo ""
