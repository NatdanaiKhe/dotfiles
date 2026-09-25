#!/usr/bin/env bash
set -euo pipefail
# Mask chrony-wait-online.service. VERIFY-BEFORE.
# Services requiring accurate time at boot (Kerberos, TLS, distributed DBs) may fail.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

echo "WARNING: chrony-wait-online.service ensures accurate time before services start."
echo "         Masking it may break Kerberos, TLS certificate validation, and"
echo "         distributed databases that require accurate time at boot."
echo ""

MASKED="$(systemctl is-masked chrony-wait-online.service 2>/dev/null || true)"
echo "Current mask status: ${MASKED}"

if [[ "$MASKED" == "masked" ]]; then
    echo "Already masked. Nothing to do."
    exit 0
fi

read -r -p "Continue? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

systemctl mask chrony-wait-online.service
echo "Done: chrony-wait-online.service masked."
