#!/usr/bin/env bash
set -euo pipefail
# Configure dracut to omit specified modules from initramfs. VERIFY-BEFORE.
# Usage: ./09-dracut-omit-modules.sh nfs iscsi
# Writes /etc/dracut.conf.d/99-omit.conf and runs dracut --force.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <module...>" >&2
    echo "Example: $0 nfs iscsi" >&2
    exit 2
fi

# Build the omit line
MODULES_STR=" $* "
CONF="/etc/dracut.conf.d/99-omit.conf"

if [[ -f "$CONF" ]]; then
    echo "=== Existing $CONF contents ==="
    cat "$CONF"
    echo "=== End existing contents ==="
    read -r -p "Overwrite this file? [y/N] " ans
    case "$ans" in
        [yY]) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
else
    read -r -p "Write $CONF? [y/N] " ans
    case "$ans" in
        [yY]) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
fi

cat > "$CONF" <<EOF
omit_dracutmodules="${MODULES_STR}"
EOF

echo "Wrote $CONF"
echo "Rebuilding initramfs..."
dracut --force

echo "Done: dracut omit modules configured and initramfs rebuilt."
