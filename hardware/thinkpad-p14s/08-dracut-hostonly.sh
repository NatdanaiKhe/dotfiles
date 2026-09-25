#!/usr/bin/env bash
set -euo pipefail
# Build host-only initramfs (--hostonly). VERIFY-BEFORE.
# Fails on different hardware; keep a rescue initramfs or live USB handy.
# Writes /etc/dracut.conf.d/99-hostonly.conf and runs dracut --force --hostonly.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

echo "RISK: A host-only initramfs will NOT boot on different hardware."
echo "       Keep a rescue initramfs or live USB handy."
echo ""

read -r -p "Continue? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

CONF="/etc/dracut.conf.d/99-hostonly.conf"

if [[ -f "$CONF" ]]; then
    echo "Overwriting existing $CONF"
fi

cat > "$CONF" <<'EOF'
hostonly="yes"
EOF

echo "Rebuilding initramfs with --hostonly..."
dracut --force --hostonly

echo "Done: initramfs rebuilt with hostonly. Keep a rescue initramfs or live USB handy."
