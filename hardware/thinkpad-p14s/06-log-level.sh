#!/usr/bin/env bash
set -euo pipefail
# Set systemd log level to warning (persistent + immediate). SAFE.
# Backs up /etc/systemd/system.conf, idempotently sets LogLevel=warning,
# then applies immediately via systemd-analyze set-log-level.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

SYS_CONF="/etc/systemd/system.conf"
BAK="${SYS_CONF}.bak.$(date +%s)"

read -r -p "Set systemd log level to warning system-wide (persistent + immediate)? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

cp "$SYS_CONF" "$BAK"
echo "Backed up to $BAK"

if grep -qE '^LogLevel=warning$' "$SYS_CONF"; then
    echo "LogLevel=warning already set in $SYS_CONF."
else
    if grep -qE '^#?LogLevel=' "$SYS_CONF"; then
        sed -i 's/^#\?LogLevel=.*/LogLevel=warning/' "$SYS_CONF"
    else
        echo 'LogLevel=warning' >> "$SYS_CONF"
    fi
    echo "Set LogLevel=warning in $SYS_CONF."
fi

echo "Applying immediately via systemd-analyze..."
systemd-analyze set-log-level warning

echo "Done: systemd log level set to warning."
