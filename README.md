# App-Auth Client

This repository contains the client-side scripts for interacting with a Keycloak instance that is secured with a custom MFA plugin.

The server-side component for this project can be found in the following repository:
[https://github.com/netzbegruenung/keycloak-mfa-plugins](https://github.com/netzbegruenung/keycloak-mfa-plugins)

# Key Generation

This section describes how to generate the `private_key.pem` and `public_key.pem` files required for this application.

The keys are generated using the Ed25519 algorithm.

## Prerequisites

You must have OpenSSL installed on your system.

## Generating the keys

1.  **Generate the private key:**
    Open your terminal and run the following command:
    ```bash
    openssl genpkey -algorithm ed25519 -out private_key.pem
    ```

2.  **Extract the public key from the private key:**
    Next, run this command to extract the public key:
    ```bash
    openssl pkey -in private_key.pem -pubout -out public_key.pem
    ```

After running these two commands, you will have `private_key.pem` and `public_key.pem` in your current directory. Make sure to keep your private key secure.

# Scripts Overview

This project contains several shell scripts for interacting with a service that requires signed requests.

-   `sign.sh`: A utility script that takes input data and signs it using the `private_key.pem`. It outputs the signature.
-   `verify.sh`: A utility script to verify a given signature against the original data and the `public_key.pem`.
-   `get-challenge.sh`: This script generates a challenge request. It creates a timestamp, signs it using `sign.sh`, and sends it as a `Signature` header to the `/challenge` endpoint.
-   `get-challenge-async.sh`: Similar to `get-challenge.sh`, but it interacts with an asynchronous version of the challenge endpoint.
-   `put-token.sh`: This script sends a device token to the registration endpoint. It signs the request payload to authenticate the request.
-   `reply-challenge.sh`: Fetches a challenge and then sends a signed reply to the `targetUrl` provided in the challenge. It accepts an optional boolean argument (`true` or `false`, defaults to `true`) to indicate if the login is granted.
