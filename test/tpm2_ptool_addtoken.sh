#!/bin/bash

set -e
set -x

tpm2_createprimary -c primary.ctx
HANDLE=$(tpm2_evictcontrol -c primary.ctx | cut -d ' ' -f 2 | head -n 1)
PID="$(tpm2_ptool init --primary-handle=$HANDLE | grep id | cut -d' ' -f2-)"
tpm2_ptool addtoken --pid=$PID --sopin= --userpin= --label=TEST
tpm2_ptool addkey --algorithm=rsa2048 --label=TEST --userpin= --key-label=TEST
TOKEN=$(p11tool --list-token-urls | grep "token=TEST")
p11tool --list-all "$TOKEN" | grep type=private | awk '{print $2}'
tpm2_ptool rmtoken --label=TEST
tpm2_evictcontrol -c $HANDLE
rm primary.ctx

