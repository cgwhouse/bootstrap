#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR"/libtw.sh

if [ $# -gt 0 ]; then
	printf "\nUsage:\n\n"
	printf "# Runs all tasks\n"
	printf "./tw.sh\n\n"
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

if ! InstallProprietaryGraphics; then
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
