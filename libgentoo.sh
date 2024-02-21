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
        return 0
    fi

    echo "...Add the following USE flags: elogind networkmanager X xinerama -kde -plasma -qt5 -qt6 -systemd -telemetry -wayland"
    echo "...Visit the wiki page for MATE and follow the instructions"
}
