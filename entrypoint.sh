#!/bin/bash
/etc/rc5.d/S01dbus start
tpm_server &
tpm2-abrmd --allow-root --tcti=mssim &
bash
