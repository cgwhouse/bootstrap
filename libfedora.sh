#!/bin/bash

source ./libbootstrap.sh

# Versions of manual stuff
#androidStudioVersion="2023.2.1.24"

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
    nvidiaHardwareCheck=$(lspci | grep NVIDIA | awk -F: '{print $NF}')
    if [ "$nvidiaHardwareCheck" == "" ]; then
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

    flathubCheck=$(sudo flatpak remotes | grep flathub)
    if [ "$flathubCheck" != "" ]; then
        return 0
    fi

    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
    echo "...Flathub repository added"
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

    # Compatibility checks
    lscpuCheck=$(lscpu | grep VT-x)
    if [ "$lscpuCheck" == "" ]; then
        return 0
    fi

    uname=$(uname -r)
    zgrepCheck=$(zgrep CONFIG_KVM /boot/config-"$uname" | grep "CONFIG_KVM_GUEST=y")
    if [ "$zgrepCheck" == "" ]; then
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

    # Ensure libvirtd and tuned services are enabled
    # This service will not stay running if in a VM, so only do this part if no VM detected
    vmCheck=$(grep hypervisor </proc/cpuinfo)

    libvirtdCheck=$(sudo systemctl is-active libvirtd.service)
    if [ "$vmCheck" == "" ] && [ "$libvirtdCheck" == "inactive" ]; then
        sudo systemctl enable --now libvirtd.service &>/dev/null
        echo "...libvirtd service enabled"
    fi

    tunedCheck=$(sudo systemctl is-active tuned.service)
    if [ "$tunedCheck" == "inactive" ]; then
        sudo systemctl enable --now tuned.service &>/dev/null
        echo "...tuned service enabled"
    fi

    # Set autostart on virtual network
    virshNetworkCheck=$(sudo virsh net-list --all --autostart | grep default)
    if [ "$virshNetworkCheck" == "" ]; then
        sudo virsh net-autostart default &>/dev/null
        echo "...Virtual network set to autostart"
    fi

    # Add regular user to libvirt group
    groupCheck=$(groups "$USER" | grep libvirt)
    if [ "$groupCheck" == "" ]; then
        sudo usermod -aG libvirt "$USER" &>/dev/null
        echo "...User added to libvirt group"
    fi
}

function InstallAndroidStudio {
    echo "TASK: InstallAndroidStudio"

    #if [ -d "$HOME"/android-studio ]; then
    #    return 0
    #fi

    #echo "...Downloading Android Studio"
    #wget -q https://redirector.gvt1.com/edgedl/android/studio/ide-zips/"$androidStudioVersion"/android-studio-"$androidStudioVersion"-linux.tar.gz
    #echo "...Unpacking Android Studio"
    #tar -xvzf android-studio-"$androidStudioVersion"-linux.tar.gz &>/dev/null
    #mv android-studio "$HOME"
    #rm -f android-studio-"$androidStudioVersion"-linux.tar.gz
    #echo "...Installed Android Studio. Run via CLI and use the in-app option for creating desktop entry"
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

    # doctl and ulauncher and dotnet sdk
    #packages=(
    #    # NetworkManager
    #    "network-manager-gnome"
    #    "network-manager-openvpn-gnome"
    #    # Doom Emacs
    #    "emacs-gtk"
    #    "elpa-ligature"
    #    "ripgrep"
    #    "fd-find"
    #    # Media + Office
    #    "vlc"
    #    "transmission-gtk"
    #    "obs-studio"
    #    "libreoffice"
    #    # Games
    #    "aisleriot"
    #    "gnome-mines"
    #    "mgba-qt"
    #    "lutris"
    #    "dolphin-emu"
    #    # Misc
    #    "gparted"
    #    "copyq"
    #    "awscli"
    #    "sshpass"
    #    "qflipper"
    #    "default-jdk"
    #)

    #for package in "${packages[@]}"; do
    #    InstallPackageIfMissing "$package"
    #done
}
