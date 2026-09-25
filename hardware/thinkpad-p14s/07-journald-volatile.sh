#!/usr/bin/env bash
set -euo pipefail
# Set journald Storage=volatile. VERIFY-BEFORE.
# Boot logs will be lost on reboot. Backs up /etc/systemd/journald.conf,
# idempotently sets Storage=volatile, then restarts systemd-journald.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

echo "TRADEOFF: journald Storage=volatile means boot logs are LOST on reboot."
echo "          Use only if you accept that tradeoff."
echo ""

read -r -p "Continue? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

JRNL_CONF="/etc/systemd/journald.conf"
BAK="${JRNL_CONF}.bak.$(date +%s)"
cp "$JRNL_CONF" "$BAK"
echo "Backed up to $BAK"

if grep -qE '^Storage=volatile$' "$JRNL_CONF"; then
    echo "Storage=volatile already set in $JRNL_CONF."
else
    if grep -qE '^#?Storage=' "$JRNL_CONF"; then
        sed -i 's/^#\?Storage=.*/Storage=volatile/' "$JRNL_CONF"
    else
        echo 'Storage=volatile' >> "$JRNL_CONF"
    fi
    echo "Set Storage=volatile in $JRNL_CONF."
fi

echo "Restarting systemd-journald..."
systemctl restart systemd-journald

echo "Done: journald storage=volatile. Boot logs will NOT persist across reboot."
