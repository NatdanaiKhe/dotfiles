#!/usr/bin/env bash
set -euo pipefail
# Mask NetworkManager-wait-online.service. VERIFY-BEFORE.
# This service delays boot waiting for a network connection.
# Run diagnostics first; only proceed if you are sure no startup services require it.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

echo "=== Checking dependencies on network-online.target ==="
systemctl list-dependencies --reverse network-online.target
echo ""

echo "=== Searching for network-online.target references in unit overrides ==="
grep -r 'network-online.target' /etc/systemd/system/ /usr/lib/systemd/system/ 2>/dev/null || true
echo ""

MASKED="$(systemctl is-masked NetworkManager-wait-online.service 2>/dev/null || true)"
echo "Current mask status: ${MASKED}"

if [[ "$MASKED" == "masked" ]]; then
    echo "Already masked. Nothing to do."
    exit 0
fi

read -r -p "Continue? Mask NetworkManager-wait-online.service? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

systemctl mask NetworkManager-wait-online.service
echo "Done: NetworkManager-wait-online.service masked."
