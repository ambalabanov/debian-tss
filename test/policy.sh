#!/bin/bash

set -x
set -e

pcr_bank="sha256"
pcr_ids="23"
hash="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"

testdata="abcde12345abcde12345"
tpm2_flushcontext -l
tpm2_createprimary -c primary.ctx
tpm2_pcrreset ${pcr_ids}
tpm2_pcrextend 23:sha256=${hash}
tpm2_pcrread "${pcr_bank}":"${pcr_ids}" -o pcr.digest
tpm2_createpolicy -g "${pcr_bank}" --policy-pcr -l "$pcr_bank":"$pcr_ids" -f pcr.digest -L pcr.policy
tpm2_create -g "${pcr_bank}" -C primary.ctx -u key.pub -r key.priv -L pcr.policy -i- <<< "$testdata"
tpm2_load -C primary.ctx -u key.pub -r key.priv -c load.ctx
testdata2=$(tpm2_unseal -c load.ctx -p pcr:${pcr_bank}:${pcr_ids})
test "x${testdata}"="x${testdata2}" || exit 1
rm -vrf primary.ctx pcr.digest pcr.policy key.pub key.priv load.ctx
tpm2_pcrreset ${pcr_ids}
