#!/bin/bash
# Switch power and fan profiles based on AC/battery state.
#
# On AC:      performance platform profile, throughput-performance tuned, aggressive thinkfan curve
# On battery: low-power platform profile, powersave tuned, quiet thinkfan curve
#
# fw-fanctrl handles its own AC/battery switching via strategyOnDischarging in config.json.

set -euo pipefail

AC_ONLINE="/sys/class/power_supply/AC/online"
PLATFORM_PROFILE="/sys/firmware/acpi/platform_profile"
THINKFAN_AC="/etc/thinkfan.yaml"
THINKFAN_BAT="/etc/thinkfan-battery.yaml"
THINKFAN_ACTIVE="/run/thinkfan-active.yaml"

if [ ! -f "$AC_ONLINE" ]; then
	exit 0
fi

if [ "$(cat "$AC_ONLINE")" = "1" ]; then
	# AC power: performance everything
	if [ -f "$PLATFORM_PROFILE" ]; then
		echo performance > "$PLATFORM_PROFILE"
	fi
	tuned-adm profile throughput-performance || true

	cp "$THINKFAN_AC" "$THINKFAN_ACTIVE"
else
	# Battery: save power
	if [ -f "$PLATFORM_PROFILE" ]; then
		echo low-power > "$PLATFORM_PROFILE"
	fi
	tuned-adm profile powersave || true

	cp "$THINKFAN_BAT" "$THINKFAN_ACTIVE"
fi

if systemctl is-active --quiet thinkfan; then
	systemctl restart thinkfan
else
	systemctl start thinkfan
fi
