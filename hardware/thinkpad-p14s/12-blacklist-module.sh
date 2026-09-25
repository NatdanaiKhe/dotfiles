#!/usr/bin/env bash
set -euo pipefail
# Blacklist a kernel module and rebuild initramfs. VERIFY-BEFORE.
# Usage: ./12-blacklist-module.sh <module>
# Appends to /etc/modprobe.d/blacklist-custom.conf and runs dracut --force.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <module>" >&2
    exit 2
fi

MODULE="$1"
CONF="/etc/modprobe.d/blacklist-custom.conf"

echo "This will blacklist '$MODULE' and rebuild initramfs."
echo "Verify no service depends on it:"
echo "  lsmod | grep $MODULE"
echo "  systemctl list-dependencies | grep -i $MODULE  # (approximate check)"
echo ""

read -r -p "Continue? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

mkdir -p /etc/modprobe.d

if [[ -f "$CONF" ]] && grep -q "$MODULE" "$CONF" 2>/dev/null; then
    echo "'$MODULE' already blacklisted in $CONF. Skipping append."
else
    {
        echo "blacklist $MODULE"
        echo "install $MODULE /bin/false"
    } >> "$CONF"
    echo "Appended blacklist + install entries for '$MODULE' to $CONF"
fi

echo "Rebuilding initramfs..."
dracut --force

echo "Done: $MODULE blacklisted; initramfs rebuilt."
