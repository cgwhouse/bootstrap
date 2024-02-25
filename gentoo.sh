#!/bin/bash

source ./libbootstrap.sh
source ./libgentoo.sh

# Validate script arguments
if [ $# -gt 1 ]; then
    printf "\nUsage:\n\n"
    printf "# Runs all tasks\n"
    printf "./gentoo.sh\n\n"
    printf "# Runs specified task only\n"
    printf "./gentoo.sh TASK_NAME\n\n"
    exit 1
fi

printf "\n"

if [ $# -eq 1 ]; then
    case $1 in
        "CreateDirectories")
            CreateDirectories
            ;;
        "InstallDesktopEnvironment")
            InstallDesktopEnvironment
            ;;
        "InstallZsh")
            InstallZsh
            ;;
        "InstallCoreUtilities")
            InstallCoreUtilities
            ;;
        "ConfigureTmux")
            ConfigureTmux
            ;;
        "ConfigureZsh")
            ConfigureZsh
            ;;
        "InstallFirefoxBin")
            InstallFirefoxBin
            ;;
        "InstallNvm")
            InstallNvm
            ;;
        "InstallPipewire")
            InstallPipewire
            ;;
        "InstallFonts")
            InstallFonts
            ;;
        "InstallUlauncher")
            InstallUlauncher
            ;;
        "InstallPlank")
            InstallPlank
            ;;
        "DownloadTheming")
            DownloadTheming
            ;;
        "InstallDotNetCore")
            InstallDotNetCore
            ;;
        "EnsureAppImage")
            EnsureAppImage
            ;;
        "InstallEmacs")
            InstallEmacs
            ;;
        "InstallObsStudio")
            InstallObsStudio
            ;;
        "InstallLibreOffice")
            InstallLibreOffice
            ;;
        "InstallAdditionalSoftware")
            InstallAdditionalSoftware
            ;;
        "InstallWebBrowsers")
            InstallWebBrowsers
            ;;

        #"InstallVirtManager")
        #    InstallVirtManager
        #    ;;

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

if ! InstallDesktopEnvironment; then
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

if ! InstallFirefoxBin; then
    exit 1
fi

if ! InstallNvm; then
    exit 1
fi

if ! InstallPipewire; then
    exit 1
fi

if ! InstallFonts; then
    exit 1
fi

if ! InstallUlauncher; then
    exit 1
fi

if ! InstallPlank; then
    exit 1
fi

if ! DownloadTheming; then
    exit 1
fi

if ! InstallDotNetCore; then
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

if ! InstallAdditionalSoftware; then
    exit 1
fi

if ! InstallWebBrowsers; then
    exit 1
fi

#if ! InstallVirtManager; then
#    exit 1
#fi

printf "\n"
