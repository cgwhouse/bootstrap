#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR"/libdebian.sh

server=false
desktop="gnome"

if [ $# -gt 0 ]; then
	printf "\nUsage:\n\n"
	printf "# Runs all tasks\n"
	printf "./debian.sh\n\n"
	exit 1
fi

printf "\n"

if ! CreateDirectories; then
	exit 1
fi

if ! InstallCoreUtilities; then
	exit 1
fi

if ! ConfigureTmux; then
	exit 1
fi

if ! InstallNvm; then
	exit 1
fi

# Exit with minimal workload if server bootstrap
if [ $server == true ]; then
	if ! ConfigureZsh; then
		exit 1
	fi

	exit 0
fi

if ! EnableMultiarch; then
	exit 1
fi

if ! InstallProprietaryGraphics; then
	exit 1
fi

if ! InstallDesktopEnvironment $desktop; then
	exit 1
fi

if ! InstallPipewire; then
	exit 1
fi

if ! InstallFonts; then
	exit 1
fi

if ! InstallFlatpak; then
	exit 1
fi

if ! InstallWebBrowsers; then
	exit 1
fi

if ! ConfigureZsh; then
	exit 1
fi

printf "\n"
