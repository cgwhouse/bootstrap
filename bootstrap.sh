#!/bin/bash

# Exit with an error if any command fails
set -e

source ./libbootstrap.sh

# Ensure root
if [ "$EUID" -ne 0 ]; then
    printf "\nRoot is required\n\n"
    exit
fi

# Check for arguments
if [ $# -gt 0 ]; then
    PrintUsageAndExit
fi

# Run bootstrap tasks
printf "\n"

InstallCoreUtilities
ConfigureCoreUtilities

printf "\n"
