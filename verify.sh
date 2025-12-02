#!/bin/bash

openssl pkeyutl -verify -pubin -inkey public.pem -rawin -in .message.bin -sigfile .signature.bin
