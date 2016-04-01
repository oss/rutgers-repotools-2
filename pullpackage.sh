#!/bin/bash
AUTO_REGEN_LOCATION="./"
MASHD="/etc/mash/"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo "Usage: pullpackage [koji tag] [RPM name in nvr format]"
	echo "Example: pullpackage centos6-rutgers-testing test-3.0-2.ru6"
	exit 0
fi

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

if [[ ! -f "$MASHD$1.mash" ]]; then
	echo "There is no mash file for that repo"
	exit 1
fi

echo "Untagging packages"
koji untag-pkg $1 $2

if [[ "$?" != "0" ]]; then
	echo "Failed to untag packages!"
	exit 1
fi

echo "Called auto-regen"
${AUTO_REGEN_LOCATION}auto-regen.sh $1
if [[ "$?" != "0" ]]; then
	echo "Auto regen failed!! Retagging package and exiting..."
	koji tag-pkg $1 $2
	exit 1
fi

echo "Successfully pushed package!"
exit 0
