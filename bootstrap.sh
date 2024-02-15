#!/bin/bash

source ./libbootstrap.sh

# Ensure root
if [ "$EUID" -ne 0 ]; then
    printf "\nRoot is required\n\n"
    exit 1
fi

# Validate no script arguments
if [ $# -gt 0 ]; then
    printf "\nUsage:\n\n"
    printf "sudo ./bootstrap.sh\n\n"
    exit 1
fi

# Ensure .env
if [ -z "$server" ] || [ -z "$username" ]; then
    printf "\nERROR: .env file is missing\n\n"
    exit 1
fi

# Run tasks, exit if a task errors

printf "\n"

if ! CreateReposDirectory; then
    exit 1
fi

if ! InstallCoreUtilities; then
    exit 1
fi

if ! ConfigureCoreUtilities; then
    exit 1
fi

if ! InstallDotNetCore; then
    exit 1
fi

# Exit with minimal workload if server bootstrap
if [ $server == true ]; then
    if ! InstallOhMyZsh; then
        exit 1
    fi
    exit 0
fi

if ! InstallProprietaryGraphics; then
    exit 1
fi

if ! InstallDesktopEnvironment; then
    exit 1
fi

if ! InstallFonts; then
    exit 1
fi

if ! InstallPipewire; then
    exit 1
fi

if ! InstallFlatpak; then
    exit 1
fi

if ! InstallDebGet; then
    exit 1
fi

if ! InstallDotNetCore; then
    exit 1
fi

if ! InstallVisualStudioCode; then
    exit 1
fi

if ! InstallWebBrowsers; then
    exit 1
fi

if ! InstallSpotify; then
    exit 1
fi

if ! InstallDoctl; then
    exit 1
fi

if ! InstallAdditionalSoftware; then
    exit 1
fi

if ! InstallOhMyZsh; then
    exit 1
fi

printf "\n"
