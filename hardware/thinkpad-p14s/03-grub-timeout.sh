#!/usr/bin/env bash
set -euo pipefail
# Reduce GRUB timeout to 1s and hide menu. SAFE.
# Backs up /etc/default/grub, idempotently sets GRUB_TIMEOUT=1 and
# GRUB_TIMEOUT_STYLE=hidden, then regenerates /boot/grub2/grub.cfg.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

GRUB_CFG="/etc/default/grub"
BAK="${GRUB_CFG}.bak.$(date +%s)"

echo "Backing up $GRUB_CFG to $BAK"
cp "$GRUB_CFG" "$BAK"

changed=0

# GRUB_TIMEOUT
if grep -qE '^GRUB_TIMEOUT=1$' "$GRUB_CFG"; then
    echo "GRUB_TIMEOUT=1 already set."
else
    if grep -qE '^#?GRUB_TIMEOUT=' "$GRUB_CFG"; then
        sed -i 's/^#\?GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' "$GRUB_CFG"
    else
        echo 'GRUB_TIMEOUT=1' >> "$GRUB_CFG"
    fi
    echo "Set GRUB_TIMEOUT=1."
    changed=1
fi

# GRUB_TIMEOUT_STYLE
if grep -qE '^GRUB_TIMEOUT_STYLE=hidden$' "$GRUB_CFG"; then
    echo "GRUB_TIMEOUT_STYLE=hidden already set."
else
    if grep -qE '^#?GRUB_TIMEOUT_STYLE=' "$GRUB_CFG"; then
        sed -i 's/^#\?GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' "$GRUB_CFG"
    else
        echo 'GRUB_TIMEOUT_STYLE=hidden' >> "$GRUB_CFG"
    fi
    echo "Set GRUB_TIMEOUT_STYLE=hidden."
    changed=1
fi

# Detect UEFI vs BIOS
if [[ -d /sys/firmware/efi ]]; then
    echo "UEFI boot detected."
else
    echo "BIOS boot detected."
fi

if [[ ! -d /boot/grub2 ]]; then
    echo "ERROR: Expected /boot/grub2/ not found — verify GRUB layout for your Fedora version before running grub2-mkconfig" >&2
    exit 1
fi

if [[ $changed -eq 1 ]]; then
    echo "Regenerating /boot/grub2/grub.cfg..."
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo "No changes needed; regenerating anyway to be safe..."
    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

echo "Done: GRUB timeout set to 1s; config regenerated."
