#!/usr/bin/env bash
#
# cleanup-high.sh — Remove HIGH-confidence unnecessary packages on Fedora 44
#
# Stops/disables Docker (kept installed). Removes old kernels, installer
# leftovers, legacy/BIOS GRUB, VM-guest tools, redundant yarn, stale duplicates.
# Podman is NOT touched.
#
# Usage:
#   ./cleanup-high.sh            # interactive, asks for confirmation
#   ./cleanup-high.sh --dry-run  # print what would be done, change nothing
#   ./cleanup-high.sh --yes      # skip confirmation prompt
#
set -euo pipefail

# ─── Config ────────────────────────────────────────────────────────────────
DRY_RUN=0
ASSUME_YES=0

# ─── Helpers ───────────────────────────────────────────────────────────────
log_info()  { printf '\033[1;34m[INFO]\033[0m  %s\n'  "$*"; }
log_ok()    { printf '\033[1;32m[ OK ]\033[0m  %s\n'  "$*"; }
log_warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n'  "$*"; }
log_err()   { printf '\033[1;31m[ERR ]\033[0m  %s\n'  "$*" >&2; }

run() {
  # Execute a command unless dry-run; always print it first.
  printf '\033[1;36m[RUN ]\033[0m  %s\n' "$*"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    eval "$@"
  fi
}

installed_pkgs() {
  # Filter a space-separated list to only packages currently installed (by rpm).
  local pkgs=() installed=()
  read -ra pkgs <<< "$1"
  for p in "${pkgs[@]}"; do
    if rpm -q "$p" >/dev/null 2>&1; then
      installed+=("$p")
    fi
  done
  printf '%s' "${installed[*]}"
}

file_exists() { [[ -f "$1" ]]; }

# ─── Parse args ────────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --yes|-y)     ASSUME_YES=1 ;;
    -h|--help)
      grep '^#' "$0" | head -20
      exit 0
      ;;
    *) log_err "Unknown flag: $arg"; exit 2 ;;
  esac
done

# ─── Preflight ─────────────────────────────────────────────────────────────
RUNNING_KERNEL="$(uname -r)"
log_info "Running kernel: $RUNNING_KERNEL"
log_info "Dry-run:  $([[ $DRY_RUN -eq 1 ]] && echo ON || echo OFF)"

# Safety: never remove the running kernel
for k in 7.1.4-204.fc44.x86_64 7.1.5-200.fc44.x86_64; do
  if [[ "$RUNNING_KERNEL" == "$k" ]]; then
    log_err "Refusing to remove the RUNNING kernel ($k). Aborting."
    exit 1
  fi
done
log_ok "Running kernel is not in the removal list."

# ─── Plan summary ──────────────────────────────────────────────────────────
cat <<'PLAN'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CLEANUP PLAN — HIGH confidence items only
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  A. Stop & disable Docker (kept installed, Podman untouched)
  B. Install glibc-langpack-en (prerequisite before removing all-langpacks)
  C. Remove 2 old kernels (7.1.4-204, 7.1.5-200)           ~1.0 GB
  D. Remove confirmed-leaf packages                          ~630 MB
       - installer leftovers (anaconda, dracut-live, livesys, gnome-initial-setup)
       - nodejs22-docs, yarnpkg
       - BIOS/32-bit-EFI GRUB (grub2-pc, grub2-efi-ia32, shim-ia32)
       - VM-guest tools (hyperv, open-vm-tools, qemu-guest, spice)
       - unused hardware (b43-fwcutter, b43-openfwwf)
       - build leftover (sassc)
       - abrt-cli, brltty
       - glibc-all-langpacks (after langpack-en installed)
  E. Remove stale duplicate rtk + backup file                ~9 MB
  F. dnf autoremove (orphaned deps)
  G. Summary

  Podman and Docker packages are NOT removed.
  Docker service is stopped & disabled only.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PLAN

if [[ "$ASSUME_YES" -eq 0 ]]; then
  printf '\n\033[1;33mProceed with cleanup?\033[0m [y/N] '
  read -r answer
  if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    log_info "Aborted. Nothing was changed."
    exit 0
  fi
fi

echo

# ─── A. Stop & disable Docker (KEEP installed) ────────────────────────────
log_info "=== A. Stop & disable Docker (NOT removing the package) ==="
run 'sudo systemctl stop docker.service docker.socket 2>/dev/null || true'
run 'sudo systemctl disable docker.service docker.socket 2>/dev/null || true'
log_ok "Docker stopped & disabled. Package kept. Podman untouched."
echo

# ─── B. Install glibc-langpack-en first ───────────────────────────────────
log_info "=== B. Install glibc-langpack-en (prerequisite) ==="
run 'sudo dnf install -y glibc-langpack-en'
log_ok "English langpack installed."
echo

# ─── C. Remove old kernels ────────────────────────────────────────────────
log_info "=== C. Remove old kernels ==="

OLD_KERNEL_PKGS=(
  kernel-7.1.4-204.fc44 kernel-core-7.1.4-204.fc44
  kernel-modules-7.1.4-204.fc44 kernel-modules-core-7.1.4-204.fc44
  kernel-modules-extra-7.1.4-204.fc44 kernel-devel-7.1.4-204.fc44
  kernel-7.1.5-200.fc44 kernel-core-7.1.5-200.fc44
  kernel-modules-7.1.5-200.fc44 kernel-modules-core-7.1.5-200.fc44
  kernel-modules-extra-7.1.5-200.fc44 kernel-devel-7.1.5-200.fc44
)
KERNEL_LIST="$(installed_pkgs "${OLD_KERNEL_PKGS[*]}")"
if [[ -n "$KERNEL_LIST" ]]; then
  log_info "Removing: $KERNEL_LIST"
  run "sudo dnf remove -y $KERNEL_LIST"
  log_ok "Old kernels removed."
else
  log_warn "No old kernel packages found — skipping."
fi
echo

# ─── D. Remove confirmed-leaf packages ────────────────────────────────────
log_info "=== D. Remove confirmed-leaf packages ==="

LEAF_PKGS=(
  # Installer / live-media leftovers
  anaconda-install-env-deps anaconda-live dracut-live dracut-config-rescue
  livesys-scripts gnome-initial-setup
  # Legacy / redundant
  # NOTE: webkit2gtk4.1 was removed from this list — gnome-shell depends on it
  # via evolution-data-server (libwebkit2gtk-4.1.so.0). NOT a leaf.
  nodejs22-docs yarnpkg
  # BIOS / 32-bit-EFI GRUB (system is 64-bit EFI)
  grub2-pc grub2-efi-ia32 grub2-efi-ia32-cdboot grub2-efi-ia32-modules shim-ia32
  # VM-guest tools (bare-metal host)
  hyperv-daemons open-vm-tools-desktop qemu-guest-agent spice-vdagent spice-webdavd
  # Unused hardware
  b43-fwcutter b43-openfwwf
  # Build leftover
  sassc
  # Misc
  abrt-cli brltty
  # Locale (after langpack-en installed in step B)
  glibc-all-langpacks
)
LEAF_LIST="$(installed_pkgs "${LEAF_PKGS[*]}")"
if [[ -n "$LEAF_LIST" ]]; then
  # Remove each leaf package individually so one hidden dependency
  # doesn't block the entire cleanup transaction.
  FAILED=()
  for pkg in $LEAF_LIST; do
    log_info "Removing: $pkg"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      printf '\033[1;36m[RUN ]\033[0m  sudo dnf remove -y %s\n' "$pkg"
    else
      OUTPUT=$(sudo dnf remove -y "$pkg" 2>&1) && RC=0 || RC=$?
      if [[ $RC -ne 0 ]]; then
        FAILED+=("$pkg")
        log_warn "Cannot remove $pkg (dnf returned $RC). Skipping."
        echo "$OUTPUT" | head -5 | sed 's/^/        /'
      else
        log_ok "Removed: $pkg"
      fi
    fi
  done
  if [[ ${#FAILED[@]} -gt 0 ]]; then
    log_warn "The following packages could not be removed: ${FAILED[*]}"
  else
    log_ok "All leaf packages removed."
  fi
else
  log_warn "No leaf packages found — skipping."
fi
echo

# ─── E. Remove stale duplicates (user home, NO sudo) ──────────────────────
log_info "=== E. Remove stale duplicate rtk & backup file ==="

RTK_CARGO="/home/natdanai/.cargo/bin/rtk"
BACKUP_FILE="/home/natdanai/.local/bin/power-lock-manager.sh.bak.20260724-194449"

if file_exists "$RTK_CARGO"; then
  log_info "Removing stale duplicate: $RTK_CARGO"
  run "rm -f '$RTK_CARGO'"
  log_ok "Stale rtk duplicate removed (live one is ~/.local/bin/rtk)."
else
  log_warn "$RTK_CARGO not found — skipping."
fi

if file_exists "$BACKUP_FILE"; then
  log_info "Removing stale backup: $BACKUP_FILE"
  run "rm -f '$BACKUP_FILE'"
  log_ok "Stale backup file removed."
else
  log_warn "$BACKUP_FILE not found — skipping."
fi
echo

# ─── F. dnf autoremove ────────────────────────────────────────────────────
log_info "=== F. Remove orphaned dependencies (dnf autoremove) ==="
run 'sudo dnf autoremove -y'
log_ok "Orphaned dependencies cleaned."
echo

# ─── G. Summary ───────────────────────────────────────────────────────────
log_info "=== SUMMARY ==="
cat <<SUMMARY
  ✓ Docker stopped & disabled (package kept, Podman untouched)
  ✓ Old kernels removed (if they were installed)
  ✓ Leaf packages removed (installer cruft, legacy webkit, VM tools, etc.)
  ✓ Stale duplicate rtk + backup file removed
  ✓ dnf autoremove completed

  Estimated space freed: ~1.6 GB (kernels + langpacks + leaf packages)

  ┃ NOTE: If kernels were removed, reboot at your convenience to
  ┃       finish cleaning up the old module directories.

  To re-enable Docker later if needed:
    sudo systemctl enable --now docker.service docker.socket
SUMMARY
echo
log_ok "Done."
