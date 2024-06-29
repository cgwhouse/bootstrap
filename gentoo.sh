#!/bin/bash

source ./libbootstrap.sh
source ./libgentoo.sh

if [ $# -gt 0 ]; then
	printf "\nUsage:\n\n"
	printf "# Runs all tasks\n"
	printf "./gentoo.sh\n\n"
	exit 1
fi

printf "\n"

if ! InstallDesktopEnvironment; then
	exit 1
fi

if ! InstallFirefoxBin; then
	exit 1
fi

# TODO: see if this works
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

if ! InstallDotNetCore; then
	exit 1
fi

if ! InstallFlatpak; then
	exit 1
fi

if ! EnsureAppImage; then
	exit 1
fi

if ! InstallEmacs; then
	exit 1
fi

if ! InstallObsStudio; then
	exit 1
fi

if ! InstallLibreOffice; then
	exit 1
fi

if ! InstallVirtManager; then
	exit 1
fi

if ! InstallDBeaver; then
	exit 1
fi

if ! InstallAws; then
	exit 1
fi

if ! InstallAdditionalSoftware; then
	exit 1
fi

if ! InstallWebBrowsers; then
	exit 1
fi

printf "\n"
