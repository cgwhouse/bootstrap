#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR"/libgentoo.sh

desktop="gnome"

if [ $# -gt 0 ]; then
	printf "\nUsage:\n\n"
	printf "# Runs all tasks\n"
	printf "./gentoo.sh\n\n"
	exit 1
fi

printf "\n"

if ! InstallDesktopEnvironment $desktop; then
	exit 1
fi

if ! InstallFirefoxBin; then
	exit 1
fi

# TODO: see if this works
# if it does, move createdirectories above pipewire and discord
if [ "$USER" == "root" ]; then
	echo "Need to login as regular user to continue the script"
	exit 1
fi

if ! InstallPipewire; then
	exit 1
fi

if ! CreateDirectories; then
	exit 1
fi

if ! InstallDiscord; then
	exit 1
fi

if ! InstallZsh; then
	exit 1
fi

if ! InstallCoreUtilities; then
	exit 1
fi

if ! ConfigureTmux; then
	exit 1
fi

if ! ConfigureZsh; then
	exit 1
fi

if ! InstallNvm; then
	exit 1
fi

if ! InstallFonts; then
	exit 1
fi

if ! InstallFlatpak; then
	exit 1
fi

if ! EnsureAppImage; then
	exit 1
fi

if ! InstallWebBrowsers; then
	exit 1
fi

printf "\n"
