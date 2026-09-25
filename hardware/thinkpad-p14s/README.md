# Fedora Boot Optimization Scripts

One script per actionable item. Run `00-baseline.sh` first, then apply fixes one at a time, reboot, re-measure with `14-self-check.sh`. Marked **SAFE** or **VERIFY-BEFORE**.

## Scripts

| Script | Risk | Description | Usage |
|---|---|---|---|
| `00-baseline.sh` | SAFE | Capture boot diagnostics (analyze, blame, critical-chain, journalctl) | `./00-baseline.sh` |
| `01-plot.sh` | SAFE | Generate SVG boot timeline plot(s) | `./01-plot.sh` |
| `02-mask-network-wait-online.sh` | VERIFY-BEFORE | Mask NetworkManager-wait-online.service | `./02-mask-network-wait-online.sh` |
| `03-grub-timeout.sh` | SAFE | Set GRUB timeout to 1s (hidden), regenerate config | `./03-grub-timeout.sh` |
| `04-mask-plymouth.sh` | VERIFY-BEFORE | Mask plymouth boot splash services | `./04-mask-plymouth.sh` |
| `05-disable-unused-services.sh` | VERIFY-BEFORE | Disable or mask a specified service | `./05-disable-unused-services.sh bluetooth.service` |
| `06-log-level.sh` | SAFE | Set systemd log level to warning (persistent + immediate) | `./06-log-level.sh` |
| `07-journald-volatile.sh` | VERIFY-BEFORE | Set journald storage to volatile (loses boot logs) | `./07-journald-volatile.sh` |
| `08-dracut-hostonly.sh` | VERIFY-BEFORE | Build host-only initramfs via dracut | `./08-dracut-hostonly.sh` |
| `09-dracut-omit-modules.sh` | VERIFY-BEFORE | Configure dracut to omit specified modules | `./09-dracut-omit-modules.sh nfs iscsi` |
| `10-multi-user-target.sh` | VERIFY-BEFORE | Set default target to multi-user (no GUI) | `./10-multi-user-target.sh` |
| `11-disable-slow-units.sh` | VERIFY-BEFORE | Disable/mask a slow service unit (prints candidate table) | `./11-disable-slow-units.sh auditd.service` |
| `12-blacklist-module.sh` | VERIFY-BEFORE | Blacklist a kernel module and rebuild initramfs | `./12-blacklist-module.sh nouveau` |
| `13-chrony-wait-online.sh` | VERIFY-BEFORE | Mask chrony-wait-online.service | `./13-chrony-wait-online.sh` |
| `14-self-check.sh` | SAFE | Re-run baseline diagnostics after reboot | `./14-self-check.sh` |

## Checklist

1. Run `./00-baseline.sh` to capture baseline boot time.
2. Run `./01-plot.sh` to generate a visual timeline.
3. Pick the biggest bottleneck from blame/critical-chain.
4. Apply ONE fix script. Reboot.
5. Run `./14-self-check.sh` to compare.
6. Repeat. One change per reboot. Measure, don't guess.

**VERIFY-BEFORE** scripts prompt for confirmation and show what they'll do.
**SAFE** scripts apply directly.
All root-requiring scripts auto-escalate via `sudo`.
