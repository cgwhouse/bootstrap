#!/bin/bash

source ./libbootstrap.sh

aptUpdated=false

# Versions of manual stuff
doctlVersion="1.105.0"
slackVersion="4.37.101"

function InstallPackageIfMissing {
    packageToCheck=$1
    grepStr="installed"

    # Handle 32-bit
    if [[ "$packageToCheck" == *":i386"* ]]; then
        # Strip i386 from the package name that was provided
        packageToCheck="${packageToCheck/:i386/""}"
        # Update the string used by grep to check if installed
        grepStr="i386 \[installed\]"
    fi

    # Check for package using apt list
    packageCheck=$(sudo apt list "$packageToCheck" 2>/dev/null | grep "$grepStr")
    if [ "$packageCheck" != "" ]; then
        return 0
    fi

    # If apt update hasn't run yet, do that now
    if [ $aptUpdated = false ]; then
        echo "...Running apt update"
        sudo apt update &>/dev/null
        aptUpdated=true
    fi

    echo "...Installing $1"
    sudo apt install -y "$1" &>/dev/null

    # Ensure package was installed, return error if not
    installCheck=$(sudo apt list "$packageToCheck" 2>/dev/null | grep "$grepStr")
    if [ "$installCheck" == "" ]; then
        echo "ERROR: Failed to install $1"
        return 1
    fi

    echo "...Successfully installed $1"
}

function InstallCoreUtilities {
    echo "TASK: InstallCoreUtilities"

    packages=(
        "neovim"
        "zsh"
        "curl"
        "wget"
        "tmux"
        "htop"
        "unar"
        "neofetch"
        "aptitude"
        "apt-transport-https"
    )

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done

    # If this is a VM, install spice guest agent
    vmCheck=$(grep hypervisor </proc/cpuinfo)
    if [ "$vmCheck" != "" ]; then
        InstallPackageIfMissing spice-vdagent
    fi
}

function InstallDotNetCore {
    echo "TASK: InstallDotNetCore"

    dotnetCheck=$(sudo apt list dotnet-sdk-8.0 2>/dev/null | grep installed)
    if [ "$dotnetCheck" != "" ]; then
        return 0
    fi

    wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb &>/dev/null
    rm packages-microsoft-prod.deb &>/dev/null

    sudo apt update &>/dev/null
    aptUpdated=true

    InstallPackageIfMissing dotnet-sdk-7.0
    InstallPackageIfMissing dotnet-sdk-8.0
}

function EnableMultiarch {
    echo "TASK: EnabledMultiarch"

    multiarchCheck=$(dpkg --print-foreign-architectures | grep i386)
    if [ "$multiarchCheck" != "" ]; then
        return 0
    fi

    sudo dpkg --add-architecture i386 &>/dev/null
    echo "...Added i386 architecture"
    sudo apt update &>/dev/null
    echo "...Updated apt sources"
}

function InstallProprietaryGraphics {
    echo "TASK: InstallProprietaryGraphics"

    # Check for NVIDIA hardware using lspci, exit if not found
    nvidiaHardwareCheck=$(lspci | grep NVIDIA | awk -F: '{print $NF}')
    if [ "$nvidiaHardwareCheck" == "" ]; then
        return 0
    fi

    # Kernel headers
    InstallPackageIfMissing linux-headers-amd64

    # non-free firmware
    InstallPackageIfMissing firmware-misc-nonfree

    # Main driver
    InstallPackageIfMissing nvidia-driver

    # 32-bit libs
    InstallPackageIfMissing nvidia-driver-libs:i386
}

function InstallDesktopEnvironment {
    echo "TASK: InstallDesktopEnvironment"

    # Display manager
    InstallPackageIfMissing lightdm

    # DE
    InstallPackageIfMissing cinnamon-desktop-environment

    # App Launcher (requires extra setup)

    # Exit if already installed
    ulauncherCheck=$(apt list ulauncher 2>/dev/null | grep installed)
    if [ "$ulauncherCheck" != "" ]; then
        return 0
    fi

    # Setup keyring using gnupg and export
    InstallPackageIfMissing gnupg
    gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176 &>/dev/null
    gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg >/dev/null

    # Add source with exported keyring to sources
    echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
          http://ppa.launchpad.net/agornostal/ulauncher/ubuntu jammy main" |
        sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list &>/dev/null

    # Do a manual apt update here so we can get the new source and install package
    # Ensure flag is true if not already
    sudo apt update &>/dev/null
    aptUpdated=true

    # Install now
    InstallPackageIfMissing ulauncher
}

function InstallMATE {
    echo "TASK: InstallMATE"

    # MATE + extras, and xscreensaver cause it adds those to MATE screensaver
    InstallPackageIfMissing mate-desktop-environment
    InstallPackageIfMissing mate-desktop-environment-extras
    InstallPackageIfMissing xscreensaver

    # Plank
    InstallPackageIfMissing plank

    DownloadPlankThemeCommon
}

function InstallQtile {
    echo "TASK: InstallQtile"

    packages=(
        # Tiling window manager
        "picom"
        "lxappearance"
        "lxsession"
        "nitrogen"
        "volumeicon-alsa"
        "arandr"
        # qtile specific
        "python-is-python3"
        "python3-pip"
        "pipx"
        "xserver-xorg"
        "xinit"
        "libpangocairo-1.0-0"
        "python3-xcffib"
        "python3-cairocffi"
        "python3-dbus-next"
    )

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done
}

function InstallPipewire {
    echo "TASK: InstallPipewire"

    InstallPackageIfMissing pipewire-audio
    InstallPackageIfMissing pavucontrol
}

function InstallFonts {
    echo "TASK: InstallFonts"

    # Nerd Fonts
    InstallFontsCommon

    InstallPackageIfMissing ttf-mscorefonts-installer
    InstallPackageIfMissing fonts-firacode
    InstallPackageIfMissing fonts-ubuntu
    InstallPackageIfMissing fonts-noto-color-emoji
}

function DownloadTheming {
    echo "TASK: DownloadTheming"

    DownloadThemingCommon

    # GTK + icons
    InstallPackageIfMissing gnome-themes-extra
}

function InstallFlatpak {
    echo "TASK: InstallFlatpak"

    InstallPackageIfMissing flatpak

    EnableFlathubRepo
}

function InstallWebBrowsers {
    echo "TASK: InstallWebBrowsers"

    InstallPackageIfMissing firefox

    # Ungoogled Chromium
    chromiumCheck=$(sudo apt list ungoogled-chromium 2>/dev/null | grep installed)
    if [ "$chromiumCheck" == "" ]; then
        echo 'deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/Debian_Sid/ /' | sudo tee /etc/apt/sources.list.d/home:ungoogled_chromium.list &>/dev/null
        curl -fsSL https://download.opensuse.org/repositories/home:ungoogled_chromium/Debian_Sid/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_ungoogled_chromium.gpg >/dev/null

        sudo apt update &>/dev/null
        aptUpdated=true

        InstallPackageIfMissing ungoogled-chromium
    fi

    # LibreWolf
    librewolfCheck=$(sudo apt list librewolf 2>/dev/null | grep installed)
    if [ "$librewolfCheck" == "" ]; then
        InstallPackageIfMissing ca-certificates

        wget -qO- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg &>/dev/null

        sudo tee /etc/apt/sources.list.d/librewolf.sources <<EOF >/dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: bookworm
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF

        sudo apt update &>/dev/null
        aptUpdated=true

        InstallPackageIfMissing librewolf
    fi
}

function InstallSpotify {
    echo "TASK: InstallSpotify"

    spotifyCheck=$(sudo apt list spotify-client 2>/dev/null | grep installed)
    if [ "$spotifyCheck" != "" ]; then
        return 0
    fi

    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg &>/dev/null
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list &>/dev/null

    sudo apt update &>/dev/null
    aptUpdated=true

    InstallPackageIfMissing spotify-client
}

function InstallVisualStudioCode {
    echo "TASK: InstallVisualStudioCode"

    vscodeCheck=$(sudo apt list code 2>/dev/null | grep installed)
    if [ "$vscodeCheck" != "" ]; then
        return 0
    fi

    InstallPackageIfMissing gpg

    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &>/dev/null

    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' &>/dev/null

    rm -f packages.microsoft.gpg

    sudo apt update &>/dev/null
    aptUpdated=true

    InstallPackageIfMissing code
}

function InstallDoctl {
    echo "TASK: InstallDoctl"

    if (hash doctl 2>/dev/null); then
        return 0
    fi

    filename="doctl-$doctlVersion-linux-amd64.tar.gz"

    wget -q https://github.com/digitalocean/doctl/releases/download/v$doctlVersion/$filename
    tar xf $filename &>/dev/null
    sudo mv doctl /usr/local/bin
    rm -f $filename
    echo "...doctl installed"
}

function InstallSlack {
    echo "TASK: InstallSlack"

    slackCheck=$(sudo apt list slack-desktop 2>/dev/null | grep installed)
    if [ "$slackCheck" != "" ]; then
        return 0
    fi

    filename="slack-desktop-$slackVersion-amd64.deb"
    wget -q https://downloads.slack-edge.com/desktop-releases/linux/x64/$slackVersion/$filename
    sudo dpkg -i $filename &>/dev/null
    rm $filename
    echo "...Slack installed"
}

function InstallVirtManager {
    echo "TASK: InstallVirtManager"

    CheckVirtManagerCompatibility

    packages=(
        "qemu-system-x86"
        "libvirt-daemon-system"
        "virtinst"
        "virt-manager"
        "virt-viewer"
        "ovmf"
        "swtpm"
        "qemu-utils"
        "guestfs-tools"
        "libosinfo-bin"
        "tuned"
        "spice-client-gtk"
    )

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done

    PerformCommonVirtManagerChecks
}

function InstallAndroidStudio {
    echo "TASK: InstallAndroidStudio"

    InstallAndroidStudioCommon
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

    packages=(
        # NetworkManager
        "network-manager-gnome"
        "network-manager-openvpn-gnome"
        # Doom Emacs
        "emacs-gtk"
        "elpa-ligature"
        "ripgrep"
        "fd-find"
        # Media + Office
        "vlc"
        "transmission-gtk"
        "obs-studio"
        "libreoffice"
        # Games
        "aisleriot"
        "gnome-mines"
        "mgba-qt"
        "lutris"
        "dolphin-emu"
        # Misc
        "gparted"
        "copyq"
        "awscli"
        "sshpass"
        "qflipper"
        "default-jdk"
    )

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done
}
