#!/bin/bash
# vim: set tabstop=8 shiftwidth=4 softtabstop=4 expandtab smarttab colorcolumn=80:

set -x
set -e

_pcr_bank="sha256"
_pcrs="23"
_hash="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
_digest="0x15A31A651841FA6D9DA392FCC21EE370019245B762161B9937929C81FA42D435"

reset_pcrs() {
    tpm2_pcrreset ${_pcrs}
}

extend_pcrs() {
    tpm2_pcrextend 23:sha256=${_hash}
}

validate_pcrs() {
    _digest_recieved=$(tpm2_pcrread "${_pcr_bank}":"${_pcrs}" | \
    grep "${_pcrs}" | awk -F': ' {'print $2'})
    test ${_digest} = ${_digest_recieved} || exit 1
}

encrypt_clevis() {
    echo -n "abcde12345abcde12345" > testdata
    clevis-encrypt-tpm2 '{"pcr_bank":"sha256","pcr_ids":"23"}' < testdata > jwe
}

decrypt_clevis() {
    clevis-decrypt-tpm2 < jwe > testdata2
}

test_clevis() {
    test $(cat testdata) = $(cat testdata2) || exit 1
}

rm_files() {
    rm -vrf testdata testdata2 jwe
}

reset_pcrs
extend_pcrs
validate_pcrs
encrypt_clevis
decrypt_clevis
test_clevis
rm_files
reset_pcrs
