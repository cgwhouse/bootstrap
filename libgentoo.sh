#!/bin/bash

source ./libbootstrap.sh

function IsPackageInstalled {
    if [ "$2" == "inOverlay" ]; then
        packageCheck=$(eix -IR "$1" | grep "No matches found")
    else
        packageCheck=$(eix -I "$1" | grep "No matches found")
    fi

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

    echo "...Add the following global USE flags, then update system: elogind gtk networkmanager X xinerama -kde -plasma -qt5 -qt6 -systemd -telemetry -wayland"
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

function InstallPipewire {
    echo "TASK: InstallPipewire"

    if ! IsPackageInstalled "media-video/pipewire"; then
        echo "...Add the following global use flag: pulseaudio screencast"
        echo "...Visit the Pipewire Gentoo wiki page for remaining instructions"
        return 1
    fi

    if ! IsPackageInstalled "media-sound/pavucontrol"; then
        echo "emerge media-sound/pavucontrol"
        return 1
    fi
}

function InstallFonts {
    echo "TASK: InstallFonts"

    # Nerd Fonts
    InstallFontsCommon

    if ! IsPackageInstalled "media-fonts/fonts-meta"; then
        echo "...emerge media-fonts/fonts-meta"
        return 1
    fi

    if ! IsPackageInstalled "media-fonts/corefonts"; then
        echo "...emerge media-fonts/corefonts"
        return 1
    fi

    if ! IsPackageInstalled "media-fonts/fira-code"; then
        echo "...emerge media-fonts/fira-code"
        return 1
    fi

    if ! IsPackageInstalled "media-fonts/ubuntu-font-family"; then
        echo "...emerge media-fonts/ubuntu-font-family"
        return 1
    fi

    if ! IsPackageInstalled "media-fonts/noto-emoji"; then
        echo "...emerge media-fonts/noto-emoji"
        return 1
    fi
}

function InstallUlauncher {
    echo "TASK: InstallUlauncher"

    if IsPackageInstalled "x11-misc/ulauncher" inOverlay; then
        return 0
    fi

    echo "...emerge x11-misc/ulauncher, only available via overlay"
    return 1
}

function InstallPlank {
    echo "TASK: InstallPlank"

    if IsPackageInstalled "x11-misc/plank" inOverlay; then
        return 0
    fi

    echo "...emerge x11-misc/plank, only available via overlay"
    return 1
}

function DownloadTheming {
    echo "TASK: Download Theming"

    DownloadThemingCommon

    if ! IsPackageInstalled "x11-themes/gnome-themes-standard"; then
        echo "...emerge x11-themes/gnome-themes-standard"
        return 1
    fi
}

function InstallDotNetCore {
    echo "TASK: InstallDotNetCore"

    if IsPackageInstalled "virtual/dotnet-sdk"; then
        return 0
    fi

    echo "...emerge virtual/dotnet-sdk, may need multiple versions"
    return 1
}

function InstallFlatpak {
    echo "TASK: InstallFlatpak"

    if IsPackageInstalled "sys-apps/flatpak"; then
        return 0
    fi

    echo "...emerge sys-apps/flatpak"
    return 1
}

function EnsureAppImage {
    echo "TASK: EnsureAppImage"

    # Fancy fuse check
    packageCheck=$(eix -I --exact sys-fs/fuse --installed-slot 0 | grep "No matches found")
    if [ "$packageCheck" == "No matches found" ]; then
        echo "...emerge sys-fs/fuse:0"
        return 1
    fi
}

function InstallSpotify {
    echo "TASK: InstallSpotify"

    if IsPackageInstalled "media-sound/spotify"; then
        return 0
    fi

    echo "...emerge media-sound/spotify"
    return 1
}

function InstallVisualStudioCode {
    echo "TASK: InstallVisualStudioCode"

    if IsPackageInstalled "app-editors/vscode"; then
        return 0
    fi

    echo "...emerge app-editors/vscode"
    return 1
}

function InstallDoctl {
    echo "TASK: InstallDoctl"

    if IsPackageInstalled "app-admin/doctl"; then
        return 0
    fi

    echo "...emerge app-admin/doctl"
    return 1
}
