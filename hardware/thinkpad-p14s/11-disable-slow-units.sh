#!/usr/bin/env bash
set -euo pipefail
# Disable/mask a slow service unit. VERIFY-BEFORE.
# Usage: ./11-disable-slow-units.sh <unit-name>
# Prints a candidate table with considerations, then delegates to 05-disable-unused-services.sh.

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

echo "=== Candidate slow units and considerations ==="
cat <<'TABLE'
  fwupd.service              - firmware daemon; disable on servers if managed manually
  akmods.service             - builds out-of-tree kmods; disable if unused
  auditd.service             - check audit.rules before disabling
  gdm.service / sddm.service / lightdm.service
                             - display manager; consider multi-user.target instead
  rngd.service               - rarely a bottleneck on modern kernels
  systemd-udev-settle.service - RISKY; often a dependency of LVM/multipath; masking can break storage
  lvm2-monitor.service       - disable only if no LVM
TABLE
echo ""

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <unit-name>" >&2
    exit 2
fi

UNIT="$1"
echo "Delegating to 05-disable-unused-services.sh for unit: $UNIT"
echo ""

exec /home/natdanai/cmd/05-disable-unused-services.sh "$UNIT"
