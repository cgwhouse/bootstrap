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
        echo "...Add the following global USE flags: pulseaudio screencast"
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

function InstallSlack {
    echo "TASK: InstallSlack"

    if IsPackageInstalled "net-im/slack"; then
        return 0
    fi

    echo "...emerge net-im/slack"
    return 1
}

function InstallAndroidStudio {
    echo "TASK: InstallAndroidStudio"

    if IsPackageInstalled "dev-util/android-studio"; then
        return 0
    fi

    echo "...emerge dev-util/android-studio"
    return 1
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

        # NetworkManager
        #"network-manager-gnome"
        #"network-manager-openvpn-gnome"
        ## Doom Emacs
        #"emacs-gtk"
        #"elpa-ligature"
        #"ripgrep"
        #"fd-find"
        ## Tiling window manager
        #"picom"
        #"lxappearance"
        #"lxsession"
        #"nitrogen"
        #"volumeicon-alsa"
        #"arandr"
        ## qtile specific
        #"python-is-python3"
        #"python3-pip"
        #"pipx"
        #"xserver-xorg"
        #"xinit"
        #"libpangocairo-1.0-0"
        #"python3-xcffib"
        #"python3-cairocffi"
        #"python3-dbus-next"
        ## Media + Office
        #"vlc"
        #"transmission-gtk"
        #"obs-studio"
        #"libreoffice"
        ## Games
        #"aisleriot"
        #"gnome-mines"
        #"mgba-qt"
        #"lutris"
        #"dolphin-emu"
        ## Misc
        #"gparted"
        #"copyq"
        #"awscli"
        #"sshpass"
        #"qflipper"
        #"openjdk-21-jdk"
}

function InstallWebBrowsers {
    echo "TASK: InstallWebBrowsers"

    # Librewolf
    if ! IsPackageInstalled "www-client/librewolf" inOverlay; then
        echo "...emerge www-client/librewolf, only available via overlay"
        return 1
    fi

    # Chromium
    if ! IsPackageInstalled "www-client/ungoogled-chromium" inOverlay; then
        echo "...Ensure the following USE flags for chromium: proprietary-codecs widevine"
        echo "...emerge www-client/ungoogled-chromium, only available via overlay"
        return 1
    fi

    # Firefox
    if ! IsPackageInstalled "www-client/firefox"; then
        echo "...replace firefox-bin with the real one"
        return 1
    fi
}
