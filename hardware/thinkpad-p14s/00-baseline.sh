#!/usr/bin/env bash
set -euo pipefail
# Capture boot-time baseline diagnostics. SAFE — read-only, no root.
# Run before optimization, then re-run 14-self-check.sh after reboot to compare.

echo "=== systemd-analyze ==="
systemd-analyze
echo ""

echo "=== systemd-analyze time ==="
systemd-analyze time
echo ""

echo "=== systemd-analyze blame (top 20) ==="
systemd-analyze blame | head -20
echo ""

echo "=== systemd-analyze critical-chain ==="
systemd-analyze critical-chain
echo ""

echo "=== journalctl warnings ==="
if command -v journalctl >/dev/null; then
    journalctl -b -p warning
else
    echo "journalctl not found; skipping."
fi
echo ""

echo "Baseline captured. Apply fixes, reboot, re-run to compare."
