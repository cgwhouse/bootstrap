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

    if IsPackageInstalled "gnome-extra/cinnamon"; then
        echo "...Add the following global USE flags, then update system: elogind gtk X -kde -plasma -qt5 -qt6 -systemd -telemetry -wayland"
        echo "...Visit the wiki pages for Cinnamon and elogind and follow the instructions"
        return 1
    fi

    if ! IsPackageInstalled "x11-misc/lightdm"; then
        echo "...emerge x11-misc/lightdm, visit the LightDM wiki page for instructions on the display manager startup script"
        return 1
    fi

    # MATE
    #if ! IsPackageInstalled "mate-base/mate"; then
    #    echo "...Add the following global USE flags, then update system: elogind gtk X xinerama -kde -plasma -qt5 -qt6 -systemd -telemetry -wayland"
    #    echo "...Visit the wiki pages for MATE, elogind, and NetworkManager, and follow the instructions"
    #    return 1
    #fi
}

function InstallZsh {
    echo "TASK: InstallZsh"

    if ! IsPackageInstalled "app-shells/zsh"; then
        echo "...Add the following global USE flag, then emerge zsh: zsh-completion"
        return 1
    fi
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

    # If this is a VM, install spice guest agent
    vmCheck=$(grep hypervisor </proc/cpuinfo)
    if [ "$vmCheck" != "" ]; then
        if ! IsPackageInstalled "spice-vdagent"; then
            echo "...emerge app-emulation/spice-vdagent"
            return 1
        fi
    fi
}

function InstallFirefoxBin {
    echo "TASK: InstallFirefoxBin"

    if ! IsPackageInstalled "www-client/firefox" || IsPackageInstalled "www-client/firefox-bin"; then
        echo "...emerge www-client/firefox-bin, web browser will help us finish setup. Will replace with source version later"
        return 1
    fi
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

    if ! IsPackageInstalled "x11-misc/ulauncher" inOverlay; then
        echo "...emerge x11-misc/ulauncher, only available via overlay"
        return 1
    fi
}

function InstallPlank {
    echo "TASK: InstallPlank"

    #if ! IsPackageInstalled "x11-misc/plank" inOverlay; then
    #    echo "...emerge x11-misc/plank, only available via overlay"
    #    return 1
    #fi
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

    if ! IsPackageInstalled "virtual/dotnet-sdk"; then
        echo "...emerge virtual/dotnet-sdk, may need multiple versions"
        return 1
    fi
}

function InstallFlatpak {
    echo "TASK: InstallFlatpak"

    if ! IsPackageInstalled "sys-apps/flatpak"; then
        echo "...emerge sys-apps/flatpak"
        return 1
    fi

    if ! IsPackageInstalled "sys-apps/xdg-desktop-portal"; then
        echo "...emerge sys-apps/xdg-desktop-portal"
        return 1
    fi

    if ! IsPackageInstalled "sys-apps/xdg-desktop-portal-gtk"; then
        echo "...emerge sys-apps/xdg-desktop-portal-gtk"
        return 1
    fi

    flathubCheck=$(sudo flatpak remotes | grep flathub)
    if [ "$flathubCheck" != "" ]; then
        return 0
    fi

    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
    echo "...Flathub repository added"
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

function InstallEmacs {
    echo "TASK: InstallEmacs"

    if ! IsPackageInstalled "app-editors/emacs"; then
        echo "...Add global USE flag: emacs"
        echo "...emerge app-editors/emacs, refer to the wiki and dotfiles for USE flags"
        return 1
    fi
}

function InstallObsStudio {
    echo "TASK: InstallObsStudio"

    if ! IsPackageInstalled "media-video/obs-studio"; then
        echo "...emerge media-video/obs-studio, check wiki for USE flags"
        return 1
    fi
}

function InstallLibreOffice {
    echo "TASK: InstallLibreOffice"

    if ! IsPackageInstalled "app-office/libreoffice"; then
        echo "...emerge app-office/libreoffice, ensure the java USE flag is enabled"
        return 1
    fi
}

function InstallVirtManager {
    echo "TASK: InstallVirtManager"

    if ! IsPackageInstalled "app-emulation/virt-manager"; then
        echo "...Visit the wiki for QEMU, libvirt, and then virt-manager"
        echo "...Once USE flags and setup are complete, emerge app-emulation/virt-manager"
        return 1
    fi

    if ! IsPackageInstalled "sys-apps/tuned"; then
        echo "...emerge sys-apps/tuned"
        return 1
    fi
}

function InstallDBeaver {
    echo "TASK: InstallDBeaver"

    if ! IsPackageInstalled "dev-db/dbeaver-bin" inOverlay; then
        echo "...emerge dev-db/dbeaver-bin, only available via overlay"
        return 1
    fi
}

function InstallAws {
    echo "TASK: InstallAws"

    if [ ! -f "/usr/local/bin/aws" ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &>/dev/null
        unzip awscliv2.zip &>/dev/null
        sudo ./aws/install &>/dev/null
        rm -f awscliv2.zip
        rm -rf aws
        echo "...Installed AWS CLI"
    fi
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

    packages=(
        # Dev stuff
        "sys-apps/ripgrep"
        "sys-apps/fd"
        "app-editors/vscode"
        "dev-util/android-studio"
        # Tiling WM
        "x11-misc/picom"
        "lxde-base/lxappearance"
        "lxde-base/lxsession"
        "x11-misc/nitrogen"
        "media-sound/volumeicon"
        "x11-misc/arandr"
        # For qtile
        "dev-python/pip"
        # Work
        "net-vpn/networkmanager-openvpn"
        "net-im/slack"
        "net-im/zoom"
        # Media + Office
        "media-video/vlc"
        "net-p2p/transmission"
        # Games
        "games-board/gnome-mines"
        "games-emulation/mgba"
        "games-util/lutris"
        "games-emulation/dolphin"
        # Misc
        "net-im/discord"
        "app-admin/doctl"
        "sys-block/gparted"
        "x11-misc/copyq"
        "net-misc/sshpass"
        "dev-java/openjdk"
    )

    for package in "${packages[@]}"; do
        if ! IsPackageInstalled "$package"; then
            echo "...emerge $package"
            return 1
        fi
    done
}

function InstallWebBrowsers {
    echo "TASK: InstallWebBrowsers"

    # Librewolf
    if ! IsPackageInstalled "www-client/librewolf" inOverlay; then
        echo "...emerge www-client/librewolf, only available via overlay"
        return 1
    fi

    # Fancy Firefox check
    firefoxCheck=$(eix -I --exact www-client/firefox | grep "No matches found")
    if [ "$firefoxCheck" == "No matches found" ]; then
        echo "...emerge www-client/firefox, may need to remove the bin version first"
        return 1
    fi

    # Chromium
    if ! IsPackageInstalled "www-client/ungoogled-chromium" inOverlay; then
        echo "...Ensure the following USE flags for chromium: proprietary-codecs widevine"
        echo "...emerge www-client/ungoogled-chromium, only available via overlay. Remember to mask vscode from this overlay."
        return 1
    fi
}
