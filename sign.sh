#!/bin/bash

if [ -z "$1" ]; then
	echo "No message supplied to be signed"
	exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo -n "$1" > "${SCRIPT_DIR}/.message.bin"
openssl pkeyutl -sign -inkey "${SCRIPT_DIR}/private.pem" -out "${SCRIPT_DIR}/.signature.bin" -rawin -in "${SCRIPT_DIR}/.message.bin"
echo "keyId:device_id,${1},signature:$(base64 "${SCRIPT_DIR}/.signature.bin" | tr -d '\n')"
