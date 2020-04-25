#!/bin/bash
# Check all disks on a machine using CloudRadar.
#
# This script should be called from /etc/smartmontools/run.d
# (maybe Debian specific?)
# and also  from crontab to check if smartd is alive.
SMARTD_STATE="$(pgrep smartd)"
SCRIPT_DIR="$(dirname $0)"
OK_STRING="All drives SMART OK." # Default message
OK_JSON="\"smart.success\": 1"

cd "${SCRIPT_DIR}"
. ./private/tokens # Include private tokens

function warn() {
	JSON="
	\"smart.warn\": \"${SMARTD_DEVICESTRING}: ${SMARTD_MESSAGE}\"
	"
}

function alert() {
	JSON="
	\"smart.alert\": \"${SMARTD_DEVICESTRING}: ${SMARTD_MESSAGE}\"
	"
}

# Everything is fine... so far
JSON="${OK_JSON}"

if [ ! $(command -v curl) ]; then
	alert "curl not found!"
fi

if [ -z "${SMARTD_STATE}" ]; then
	alert "smartd not running!"
	exit 0
fi

if [ -n "${SMARTD_MESSAGE}" ]; then
	alert "${SMARTD_DEVICESTRING}: ${SMARTD_MESSAGE}"
fi

#case $SMARTD_MESSAGE in
#	"ALERT")
#		alert "${SMARTD_DEVICESTRING}:  ${SMARTD_MESSAGE}"
#	;;
#	"WARN")
#		warn "${SMARTD_DEVICESTRING}: ${SMARTD_MESSAGE}"
#	;;
#	*)
#		# Everything is fine.
#		CHECK_STRING="All drives SMART OK."
#		SUCCESS=1
#	;;
#esac

curl -X POST \
	https://hub.cloudradar.io/cct/ \
	-H "X-CustomCheck-Token: ${smart_TOKEN}" \
	-d "{
		${JSON}
	  }"
