#!/bin/bash

echo "================================="
echo " Fedora Power Configuration Check"
echo "================================="
echo

echo "== Power Source =="
if ls /sys/class/power_supply/AC*/online >/dev/null 2>&1; then
    AC=$(cat /sys/class/power_supply/AC*/online)
    if [ "$AC" = "1" ]; then
        echo "Charger: Connected"
    else
        echo "Charger: Disconnected (Battery)"
    fi
else
    echo "No AC adapter detected"
fi

echo

echo "== GNOME Screen Lock =="
echo "Lock enabled:"
gsettings get org.gnome.desktop.screensaver lock-enabled

echo "Idle timeout:"
gsettings get org.gnome.desktop.session idle-delay

echo

echo "== GNOME Power Suspend =="
echo "AC suspend:"
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type

echo "AC suspend timeout:"
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout

echo

echo "Battery suspend:"
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type

echo "Battery suspend timeout:"
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout

echo

echo "== Lid Configuration =="
if [ -d /etc/systemd/logind.conf.d ]; then
    grep -R "HandleLidSwitch" /etc/systemd/logind.conf.d 2>/dev/null
else
    echo "No custom lid configuration"
fi

echo

echo "== systemd User Timer =="
systemctl --user status power-lock-manager.timer --no-pager 2>/dev/null | grep -E "Active|Trigger|NEXT|LAST"

echo

echo "== Expected Behavior =="
echo "AC:"
echo "  Lock: disabled"
echo "  Suspend: disabled"
echo
echo "Battery:"
echo "  Lock: 5 minutes"
echo "  Suspend: 5 minutes"
echo
echo "Lid:"
echo "  Suspend"
