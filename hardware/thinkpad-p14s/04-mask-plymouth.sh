#!/usr/bin/env bash
set -euo pipefail
# Mask plymouth boot splash services. VERIFY-BEFORE.
# Removes boot splash screen. Recommend also removing 'rhgb quiet' from
# GRUB_CMDLINE_LINUX in /etc/default/grub and regenerating grub config.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

UNITS=(
    plymouth-quit-wait.service
    plymouth-start.service
    plymouth-read-write.service
)

echo "WARNING: This masks plymouth boot splash services."
echo "         If you mask these, you should also remove 'rhgb quiet'"
echo "         from GRUB_CMDLINE_LINUX in /etc/default/grub and re-run"
echo "         grub2-mkconfig (or 03-grub-timeout.sh) to regenerate."
echo ""

read -r -p "Continue? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

for unit in "${UNITS[@]}"; do
    mask_status="$(systemctl is-masked "$unit" 2>/dev/null || true)"
    if [[ "$mask_status" == "masked" ]]; then
        echo "$unit is already masked. Skipping."
    else
        echo "Masking $unit..."
        systemctl mask "$unit"
    fi
done

echo "Done: plymouth masked. Remember to remove 'rhgb quiet' from /etc/default/grub and run 03-grub-timeout.sh (or grub2-mkconfig) to regenerate."
