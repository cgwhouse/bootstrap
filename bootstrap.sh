#!/bin/bash

source ./libbootstrap.sh

# Ensure root
if [ "$EUID" -ne 0 ]; then
    printf "\nRoot is required\n\n"
    exit 1
fi

# Check for arguments
if [ $# -gt 0 ]; then
    printf "\nUsage:\n\n"
    printf "sudo ./bootstrap.sh\n\n"
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

# Should always be last, because install script drops you into a zsh at the end
if ! InstallOhMyZsh; then
    exit 1
fi

printf "\n"
