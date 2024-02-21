#!/bin/bash

source ./libbootstrap.sh
source ./libgentoo.sh

# Validate script arguments
if [ $# -gt 1 ]; then
    printf "\nUsage:\n\n"
    printf "# Runs all tasks\n"
    printf "./bootstrap-gentoo.sh\n\n"
    printf "# Runs specified task only\n"
    printf "./bootstrap-gentoo.sh TASK_NAME\n\n"
    exit 1
fi

printf "\n"

if [ $# -eq 1 ]; then
    case $1 in
        "InstallDesktopEnvironment")
            InstallDesktopEnvironment
            ;;
        "CreateDirectories")
            CreateDirectories
            ;;
        #"InstallCoreUtilities")
        #    InstallCoreUtilities
        #    ;;
        "ConfigureCoreUtilities")
            ConfigureCoreUtilities
            ;;
        #"InstallDotNetCore")
        #    InstallDotNetCore
        #    ;;
        "InstallNvm")
            InstallNvm
            ;;
        "InstallOhMyZsh")
            InstallOhMyZsh
            ;;
        #"EnableMultiarch")
        #    EnableMultiarch
        #    ;;
        #"InstallProprietaryGraphics")
        #    InstallProprietaryGraphics
        #    ;;
        #"InstallDesktopEnvironment")
        #    InstallDesktopEnvironment
        #    ;;
        #"InstallPipewire")
        #    InstallPipewire
        #    ;;
        #"InstallFonts")
        #    InstallFonts
        #    ;;
        #"DownloadTheming")
        #    DownloadTheming
        #    ;;
        #"InstallDebGet")
        #    InstallDebGet
        #    ;;
        #"InstallFlatpak")
        #    InstallFlatpak
        #    ;;
        #"InstallWebBrowsers")
        #    InstallWebBrowsers
        #    ;;
        #"InstallSpotify")
        #    InstallSpotify
        #    ;;
        #"InstallVisualStudioCode")
        #    InstallVisualStudioCode
        #    ;;
        #"InstallDoctl")
        #    InstallDoctl
        #    ;;
        #"InstallSlack")
        #    InstallSlack
        #    ;;
        #"InstallVirtManager")
        #    InstallVirtManager
        #    ;;
        #"InstallAndroidStudio")
        #    InstallAndroidStudio
        #    ;;
        #"InstallAdditionalSoftware")
        #    InstallAdditionalSoftware
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

#if ! InstallCoreUtilities; then
#    exit 1
#fi

if ! ConfigureCoreUtilities; then
    exit 1
fi

#if ! InstallDotNetCore; then
#    exit 1
#fi

if ! InstallNvm; then
    exit 1
fi

#if ! EnableMultiarch; then
#    exit 1
#fi
#
#if ! InstallProprietaryGraphics; then
#    exit 1
#fi
#
#if ! InstallDesktopEnvironment; then
#    exit 1
#fi
#
#if ! InstallPipewire; then
#    exit 1
#fi
#
#if ! InstallFonts; then
#    exit 1
#fi
#
#if ! DownloadTheming; then
#    exit 1
#fi
#
#if ! InstallDebGet; then
#    exit 1
#fi
#
#if ! InstallFlatpak; then
#    exit 1
#fi
#
#if ! InstallWebBrowsers; then
#    exit 1
#fi
#
#if ! InstallSpotify; then
#    exit 1
#fi
#
#if ! InstallVisualStudioCode; then
#    exit 1
#fi
#
#if ! InstallDoctl; then
#    exit 1
#fi
#
#if ! InstallSlack; then
#    exit 1
#fi
#
#if ! InstallVirtManager; then
#    exit 1
#fi
#
#if ! InstallAndroidStudio; then
#    exit 1
#fi
#
#if ! InstallAdditionalSoftware; then
#    exit 1
#fi

if ! InstallOhMyZsh; then
    exit 1
fi

printf "\n"
