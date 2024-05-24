#!/bin/bash

source ./libbootstrap.sh
source ./libfedora.sh

# Validate script arguments
if [ $# -gt 1 ]; then
	printf "\nUsage:\n\n"
	printf "# Runs all tasks\n"
	printf "./fedora.sh\n\n"
	printf "# Runs specified task only\n"
	printf "./fedora.sh TASK_NAME\n\n"
	exit 1
fi

printf "\n"

if [ $# -eq 1 ]; then
	case $1 in
	"CreateDirectories")
		CreateDirectories
		;;
	"InstallCoreUtilities")
		InstallCoreUtilities
		;;
	"ConfigureTmux")
		ConfigureTmux
		;;
	"InstallNvm")
		InstallNvm
		;;
	"ConfigureZsh")
		ConfigureZsh
		;;
	"InstallProprietaryGraphics")
		InstallProprietaryGraphics
		;;
	"InstallFonts")
		InstallFonts
		;;
	"DownloadTheming")
		DownloadTheming
		;;
	"InstallFlatpak")
		InstallFlatpak
		;;
	"InstallWebBrowsers")
		InstallWebBrowsers
		;;
	"InstallVisualStudioCode")
		InstallVisualStudioCode
		;;
	"InstallVirtManager")
		InstallVirtManager
		;;
	"InstallAws")
		InstallAws
		;;
	"InstallAdditionalSoftware")
		InstallAdditionalSoftware
		;;
	*)
		printf "ERROR: Unknown task\n\n"
		exit 1
		;;
	esac

	printf "\n"
	exit 0
fi

# Full run, exit if a task errors

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

if ! DownloadTheming; then
	exit 1
fi

if ! InstallFlatpak; then
	exit 1
fi

if ! InstallWebBrowsers; then
	exit 1
fi

if ! InstallVisualStudioCode; then
	exit 1
fi

if ! InstallVirtManager; then
	exit 1
fi

if ! InstallAws; then
	exit 1
fi

if ! InstallAdditionalSoftware; then
	exit 1
fi

if ! ConfigureZsh; then
	exit 1
fi

printf "\n"
