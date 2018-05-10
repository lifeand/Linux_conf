#!/bin/sh

XUSER=$(ps aux | grep awesome | awk '{print $1}' | head -n1)

su $XUSER -c "amixer set Master toggle"
