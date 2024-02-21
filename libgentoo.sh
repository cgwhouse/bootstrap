#!/bin/bash

function IsPackageInstalled {
    packageCheck=$(eix -I "$1" | grep "No matches found")
    if [ "$packageCheck" != "" ]; then
        return 1
    fi

    return 0
}

function InstallDesktopEnvironment {
    echo "TASK: InstallDesktopEnvironment"

    if IsPackageInstalled "mate-base/mate" ; then
        echo "package is installed"
    else
        echo "package not installed"
    fi
}
