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

    if IsPackageInstalled "mate-base/mate"; then
        return 0
    fi

    echo "...Add the following USE flags, then update system: elogind gtk networkmanager X xinerama -kde -plasma -qt5 -qt6 -systemd -telemetry -wayland"
    echo "...Visit the wiki pages for MATE, elogind, and NetworkManager, and follow the instructions"
    return 1
}

function InstallZsh {
    echo "TASK: InstallZsh"

    if IsPackageInstalled "app-shells/zsh"; then
        return 0
    fi

    echo "...Add the following global USE flag, then emerge zsh: zsh-completion"
    return 1
}

function InstallCoreUtilities {
    echo "TASK: InstallCoreUtilities"

    if ! IsPackageInstalled "app-misc/tmux"; then
        echo "...emerge app-misc/tmux"
        return 1
    fi

    if ! IsPackageInstalled "app-arch/unar"; then
        echo "...emerge app-arch/unar"
        return 1
    fi

    if ! IsPackageInstalled "app-misc/fastfetch"; then
        echo "...emerge app-misc/fastfetch"
        return 1
    fi

    if ! IsPackageInstalled "sys-process/htop"; then
        echo "...emerge sys-process/htop"
        return 1
    fi
}

function InstallFirefox {
    echo "TASK: InstallFirefox"

    if IsPackageInstalled "www-client/firefox" || IsPackageInstalled "www-client/firefox-bin"; then
        return 0
    fi

    echo "...Firefox can be emerged normally, we need a web browser to stop relying on another computer for remaining setup!"
    return 1
}
