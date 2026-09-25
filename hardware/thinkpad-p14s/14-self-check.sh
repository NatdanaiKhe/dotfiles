#!/usr/bin/env bash
set -euo pipefail
# Re-measure boot after applying fixes. SAFE — read-only, no root.
# Run after reboot to compare against baseline from 00-baseline.sh.

exec /home/natdanai/cmd/00-baseline.sh
