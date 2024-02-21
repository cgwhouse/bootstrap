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

    echo "...Add the following USE flags, then update system: elogind networkmanager X xinerama -kde -plasma -qt5 -qt6 -systemd -telemetry -wayland"
    echo "...Visit the wiki pages for MATE, elogind, and NetworkManager, and follow the instructions"
    return 1
}

function InstallFirefox {
   echo "TASK: InstallFirefox"

    if IsPackageInstalled "www-client/firefox" ; then
        return 0
    fi

    echo "...Firefox can be emerged normally, we need a web browser to stop relying on another computer for this"
    return 1

}
