#!/usr/bin/env bash
set -euo pipefail
# Generate SVG boot timeline(s). SAFE — read-only, no root.

OUTDIR="/home/natdanai/cmd"

echo "Generating boot SVG plot..."
systemd-analyze plot > "${OUTDIR}/boot.svg"
echo "Wrote: ${OUTDIR}/boot.svg"

if systemd-analyze plot --help 2>&1 | grep -q -- '--no-legend'; then
    systemd-analyze plot --no-legend > "${OUTDIR}/boot-no-legend.svg"
    echo "Wrote: ${OUTDIR}/boot-no-legend.svg"
else
    echo "plot --no-legend not supported on this systemd version; skipping."
fi

echo "Done: SVG timeline(s) written to ~/cmd/."
