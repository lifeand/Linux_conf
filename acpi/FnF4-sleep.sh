#!/bin/sh
logger "[ACPI] Fn+F4 pressed, start slimlock for current user and suspend to ram"
XUSER=$(ps aux |grep awesome |awk '{print $1}' | head -n1)
sudo -u $XUSER /usr/bin/slimlock
echo -n mem >/sys/power/state
