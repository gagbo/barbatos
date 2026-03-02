#!/bin/bash
# Switch thinkfan between aggressive (AC) and quiet (battery) profiles.

set -euo pipefail

AC_ONLINE="/sys/class/power_supply/AC/online"
THINKFAN_AC="/etc/thinkfan.yaml"
THINKFAN_BAT="/etc/thinkfan-battery.yaml"
THINKFAN_ACTIVE="/run/thinkfan-active.yaml"

if [ ! -f "$AC_ONLINE" ]; then
	exit 0
fi

if [ "$(cat "$AC_ONLINE")" = "1" ]; then
	cp "$THINKFAN_AC" "$THINKFAN_ACTIVE"
else
	cp "$THINKFAN_BAT" "$THINKFAN_ACTIVE"
fi

if systemctl is-active --quiet thinkfan; then
	systemctl restart thinkfan
else
	systemctl start thinkfan
fi
