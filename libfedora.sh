#!/bin/bash

source ./libbootstrap.sh

function InstallPackageIfMissing {
    packageToCheck=$1
    grepStr="Installed Packages"

    # Check for package using dnf list
    packageCheck=$(sudo dnf list "$packageToCheck" 2>/dev/null | grep "$grepStr")
    if [ "$packageCheck" != "" ]; then
        return 0
    fi

    echo "...Installing $1"
    sudo dnf install -y "$1" &>/dev/null

    # Ensure package was installed, return error if not
    installCheck=$(sudo dnf list "$packageToCheck" 2>/dev/null | grep "$grepStr")
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
        "python3-neovim"
        "zsh"
        "curl"
        "wget2"
        "tmux"
        "htop"
        "unar"
        "fastfetch"
        "python3-dnf-plugin-rpmconf"
    )

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done
}

function InstallProprietaryGraphics {
    echo "TASK: InstallProprietaryGraphics"

    # Check for NVIDIA hardware using lspci, exit if not found
    if ! PerformNvidiaHardwareCheck; then
        return 0
    fi

    # Main driver
    InstallPackageIfMissing akmod-nvidia

    # nvenc support
    InstallPackageIfMissing xorg-x11-drv-nvidia-cuda
    InstallPackageIfMissing xorg-x11-drv-nvidia-cuda-libs

    # Video acceleration
    InstallPackageIfMissing nvidia-vaapi-driver
    InstallPackageIfMissing libva-utils
    InstallPackageIfMissing vdpauinfo

    # Vulkan support
    InstallPackageIfMissing vulkan
}

function InstallFonts {
    echo "TASK: InstallFonts"

    # Nerd Fonts
    InstallFontsCommon

    # Metapackages for default font set, and emojis
    InstallPackageIfMissing default-fonts
    InstallPackageIfMissing default-fonts-core-emoji

    # FiraCode
    InstallPackageIfMissing fira-code-fonts

    # Ubuntu
    coprCheck=$(sudo dnf copr list | grep "ubuntu-fonts")
    if [ "$coprCheck" == "" ]; then
        sudo dnf copr enable -y atim/ubuntu-fonts &>/dev/null
        echo "...ubuntu-fonts copr repository enabled"
    fi

    InstallPackageIfMissing ubuntu-family-fonts

    # Microsoft fonts
    InstallPackageIfMissing cabextract
    InstallPackageIfMissing xorg-x11-font-utils
    InstallPackageIfMissing fontconfig

    if [ -d "/usr/share/fonts/msttcore" ]; then
        return 0
    fi

    sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm &>/dev/null
    echo "...Installed MSFT fonts"
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
    coprCheck=$(sudo dnf copr list | grep "ungoogled-chromium")
    if [ "$coprCheck" == "" ]; then
        sudo dnf copr enable -y wojnilowicz/ungoogled-chromium &>/dev/null
        echo "...ungoogled-chromium copr repository enabled"
    fi

    InstallPackageIfMissing ungoogled-chromium

    # LibreWolf
    librewolfRepoCheck=$(dnf repolist | grep "LibreWolf")
    if [ "$librewolfRepoCheck" == "" ]; then
        curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo &>/dev/null
        echo "...LibreWolf repo enabled"
    fi

    InstallPackageIfMissing librewolf
}

function InstallVisualStudioCode {
    echo "TASK: InstallVisualStudioCode"

    vscodeCheck=$(dnf repolist | grep "Visual Studio Code")
    if [ "$vscodeCheck" == "" ]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &>/dev/null
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
        echo "...VS Code repo enabled"
    fi

    InstallPackageIfMissing code
}

function InstallVirtManager {
    echo "TASK: InstallVirtManager"

    if ! CheckVirtManagerCompatibility; then
        return 0
    fi

    packages=(
        "qemu-kvm"
        "libvirt"
        "virt-install"
        "virt-manager"
        "virt-viewer"
        "edk2-ovmf"
        "swtpm"
        "qemu-img"
        "guestfs-tools"
        "libosinfo"
        "tuned"
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

function InstallAws {
    echo "TASK: InstallAws"

    InstallAwsCommon
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

    packages=(
        "doctl"
        "ulauncher"
        "dotnet-sdk-8.0"
        "NetworkManager-openvpn"
        # Doom Emacs
        "emacs"
        "ripgrep"
        "fd-find"
        # Media + Office
        "vlc"
        "transmission"
        "obs-studio"
        "libreoffice"
        # Games
        "aisleriot"
        "gnome-mines"
        "libretro-mgba"
        "lutris"
        "dolphin-emu"
        # Misc
        "gparted"
        "copyq"
        "sshpass"
        "qflipper"
        "java-17-openjdk"
    )

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done
}
