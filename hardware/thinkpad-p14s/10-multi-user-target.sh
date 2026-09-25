#!/usr/bin/env bash
set -euo pipefail
# Set default systemd target to multi-user.target (no GUI). VERIFY-BEFORE.
# Reverse with: sudo systemctl set-default graphical.target

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

CURRENT="$(systemctl get-default)"
echo "Current default target: $CURRENT"
echo ""
echo "TRADEOFF: Switching to multi-user.target = no graphical login (no GUI)."
echo ""

read -r -p "Continue? [y/N] " ans
case "$ans" in
    [yY]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

systemctl set-default multi-user.target
echo "Done: default target is multi-user. Reverse with: sudo systemctl set-default graphical.target"
