#!/usr/bin/env bash
set -euo pipefail
# Disable or mask a specified systemd service. VERIFY-BEFORE.
# Provide the unit name as an argument.
# Candidate units: bluetooth.service, cups.service, cups-browsed.service,
#   ModemManager.service, avahi-daemon.service, geoclue.service, packagekit.service

if [[ $EUID -ne 0 ]]; then
    exec sudo -E "$0" "$@"
fi

CANDIDATES=(
    bluetooth.service
    cups.service
    cups-browsed.service
    ModemManager.service
    avahi-daemon.service
    geoclue.service
    packagekit.service
)

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <unit-name>" >&2
    echo "" >&2
    echo "Candidate units from the guide:" >&2
    for c in "${CANDIDATES[@]}"; do
        echo "  $c" >&2
    done
    exit 2
fi

UNIT="$1"

# Verify unit exists
if ! systemctl cat "$UNIT" >/dev/null 2>&1; then
    echo "Unit not found: $UNIT" >&2
    exit 1
fi

DESC="$(systemctl show -p Description --value "$UNIT" 2>/dev/null || echo "N/A")"
ENABLED="$(systemctl is-enabled "$UNIT" 2>/dev/null || echo "disabled/unknown")"
ACTIVE="$(systemctl is-active "$UNIT" 2>/dev/null || echo "inactive")"

echo "Unit:        $UNIT"
echo "Description: $DESC"
echo "Enabled:     $ENABLED"
echo "Active:      $ACTIVE"
echo ""

read -r -p "Disable or mask? [d/m/N] " ans
case "$ans" in
    d)
        systemctl disable "$UNIT"
        echo "Done: $UNIT disabled."
        ;;
    m)
        systemctl mask "$UNIT"
        echo "Done: $UNIT masked."
        ;;
    *)
        echo "Aborted."
        exit 0
        ;;
esac
