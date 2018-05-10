#!/bin/sh
logger "[ACPI] Fn+F3 pressed, start slimlock for logged in user"
XUSER=$(ps aux | grep awesome| awk '{print $1}' | head -n1)
sudo -u $XUSER /usr/bin/slimlock
