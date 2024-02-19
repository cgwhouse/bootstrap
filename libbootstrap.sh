#!/bin/bash

aptUpdated=false

# Versions of manual stuff
doctlVersion="1.104.0"
slackVersion="4.36.140"
androidStudioVersion="2023.1.1.28"

function InstallPackageIfMissing {
    # Check for package using apt list
    packageCheck=$(sudo apt list "$1" 2>/dev/null | grep installed)
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
    installCheck=$(sudo apt list "$1" 2>/dev/null | grep installed)
    if [ "$installCheck" == "" ]; then
        echo "ERROR: Failed to install $1"
        return 1
    fi

    echo "...Successfully installed $1"
}

function CreateDirectories {
    echo "TASK: CreateDirectories"

    if [ ! -d "$HOME"/repos ]; then
        mkdir "$HOME"/repos &>/dev/null
        echo "...Created repos directory"
    fi

    if [ ! -d "$HOME"/repos/theming ]; then
        mkdir "$HOME"/repos/theming &>/dev/null
        echo "...Created theming directory"
    fi

    if [ ! -d "$HOME"/Pictures ]; then
        mkdir "$HOME"/Pictures &>/dev/null
        echo "...Created Pictures directory"
    fi

    if [ ! -d "$HOME"/Pictures/wallpapers ]; then
        mkdir "$HOME"/Pictures/wallpapers &>/dev/null
        echo "...Created wallpapers directory"
    fi

    if [ ! -d "$HOME"/.cache ]; then
        mkdir "$HOME"/.cache &>/dev/null
        echo "...Created .cache directory"
    fi

    if [ ! -d "$HOME/.local" ]; then
        mkdir "$HOME"/.local
        echo "...Created .local directory"
    fi

    if [ ! -d "$HOME/.local/share" ]; then
        mkdir "$HOME"/.local/share
        echo "...Created local share directory"
    fi

    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir "$HOME"/.local/bin
        echo "...Created local bin directory"
    fi
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

function ConfigureCoreUtilities {
    echo "TASK: ConfigureCoreUtilities"

    # Ensure zsh is default shell for user
    userShell=$(getent passwd "$USER" | awk -F: '{print $NF}')
    if [ "$userShell" != "/usr/bin/zsh" ]; then
        echo "...Changing default shell to zsh"
        sudo usermod --shell /usr/bin/zsh "$USER" &>/dev/null
        echo "...Default shell changed to zsh"
    fi

    # Oh My Tmux
    ohMyTmuxPath="$HOME/.tmux"
    if [ ! -d "$ohMyTmuxPath" ]; then
        echo "...Installing Oh My Tmux"

        git clone https://github.com/gpakosz/.tmux.git "$ohMyTmuxPath" &>/dev/null
        ln -s -f "$ohMyTmuxPath"/.tmux.conf "$HOME"/.tmux.conf &>/dev/null
        cp "$ohMyTmuxPath"/.tmux.conf.local "$HOME"/ &>/dev/null

        echo "...Successfully installed Oh My Tmux"
    fi

    # Ensure Tmux is fully configured, exit if not
    # Check for commented out mouse mode as the check, the default config has this
    if grep -Fxq "#set -g mouse on" "$HOME"/.tmux.conf.local; then
        echo "...WARNING: Oh My Tmux still needs to be configured"
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

function InstallNvm {
    echo "TASK: InstallNvm"

    if [ ! -d "$HOME"/.nvm ]; then
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash &>/dev/null
        echo "...nvm installed"
    fi
}

function InstallOhMyZsh {
    echo "TASK: InstallOhMyZsh"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "...Installing Oh My Zsh, you will be dropped into a new zsh session at the end"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
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
}

function InstallDesktopEnvironment {
    echo "TASK: InstallDesktopEnvironment"

    # Display manager
    InstallPackageIfMissing lightdm

    # Standard MATE + extras
    InstallPackageIfMissing mate-desktop-environment
    InstallPackageIfMissing mate-desktop-environment-extras
    InstallPackageIfMissing xscreensaver

    # Dock
    InstallPackageIfMissing plank

    # App Launcher (requires extra setup)

    # Exit if already installed
    ulauncherCheck=$(apt list ulauncher | grep installed)
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

function InstallPipewire {
    echo "TASK: InstallPipewire"

    InstallPackageIfMissing pipewire-audio
    InstallPackageIfMissing pavucontrol
}

function InstallFonts {
    echo "TASK: InstallFonts"

    if [ ! -d "$HOME/.local/share/fonts" ]; then
        mkdir "$HOME"/.local/share/fonts
        echo "...Fonts directory created"
    fi

    # MSFT
    InstallPackageIfMissing ttf-mscorefonts-installer

    # Fira Code + Nerd Font
    InstallPackageIfMissing fonts-firacode

    firaCodeNerdFontCheck="$HOME/.local/share/fonts/FiraCodeNerdFont-Regular.ttf"
    if [ ! -f "$firaCodeNerdFontCheck" ]; then
        echo "...Installing FiraCode Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -o fira.zip &>/dev/null
        unar -d fira.zip &>/dev/null
        cp fira/*.ttf "$HOME"/.local/share/fonts &>/dev/null
        rm -r fira &>/dev/null
        rm fira.zip &>/dev/null
        echo "...FiraCode Nerd Font installed"
    fi

    # Ubuntu + Nerd Font + UbuntuMono Nerd Font
    InstallPackageIfMissing fonts-ubuntu

    ubuntuNerdFontCheck="$HOME/.local/share/fonts/UbuntuNerdFont-Regular.ttf"
    if [ ! -f "$ubuntuNerdFontCheck" ]; then
        echo "...Installing Ubuntu Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Ubuntu.zip -o ubuntu.zip &>/dev/null
        unar -d ubuntu.zip &>/dev/null
        cp ubuntu/*.ttf "$HOME"/.local/share/fonts &>/dev/null
        rm -r ubuntu &>/dev/null
        rm ubuntu.zip &>/dev/null
        echo "...Ubuntu Nerd Font installed"
    fi

    ubuntuMonoNerdFontCheck="$HOME/.local/share/fonts/UbuntuMonoNerdFont-Regular.ttf"
    if [ ! -f "$ubuntuMonoNerdFontCheck" ]; then
        echo "...Installing UbuntuMono Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip -o ubuntumono.zip &>/dev/null
        unar -d ubuntumono.zip &>/dev/null
        cp ubuntumono/*.ttf "$HOME"/.local/share/fonts &>/dev/null
        rm -r ubuntumono &>/dev/null
        rm ubuntumono.zip &>/dev/null
        echo "...UbuntuMono Nerd Font installed"
    fi

    # Noto Emoji
    InstallPackageIfMissing fonts-noto-color-emoji
}

function DownloadTheming {
    echo "TASK: DownloadTheming"

    # GTK + icons
    InstallPackageIfMissing gnome-themes-extra

    if [ ! -d "$HOME"/.themes ]; then
        mkdir "$HOME"/.themes &>/dev/null
        echo "...Created .themes directory"
    fi

    if [ ! -d "$HOME"/.themes/Catppuccin-Mocha-Standard-Green-Dark ]; then
        wget -q https://github.com/catppuccin/gtk/releases/latest/download/Catppuccin-Mocha-Standard-Green-Dark.zip
        unar -d Catppuccin-Mocha-Standard-Green-Dark.zip &>/dev/null
        mv Catppuccin-Mocha-Standard-Green-Dark/Catppuccin-Mocha-Standard-Green-Dark "$HOME"/.themes &>/dev/null
        rm -rf Catppuccin-Mocha-Standard-Green-Dark &>/dev/null
        rm -f Catppuccin-Mocha-Standard-Green-Dark.zip &>/dev/null
        echo "...Installed Catppuccin GTK theme"
    fi

    if [ ! -d "$HOME"/.local/share/icons ]; then
        mkdir "$HOME"/.local/share/icons &>/dev/null
        echo "...Created icons directory"
    fi

    if [ ! -d "$HOME"/.local/share/icons/Tela-circle-dark ]; then
        mkdir "$HOME"/repos/theming/Tela-circle-dark
        git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git "$HOME"/repos/theming/Tela-circle-dark &>/dev/null
        "$HOME"/repos/theming/Tela-circle-dark/install.sh -a -c -d "$HOME"/.local/share/icons &>/dev/null
        echo "...Installed Tela-circle icon themes"
    fi

    # Ulauncher
    if [ ! -d "$HOME"/.config/ulauncher/user-themes/Catppuccin-Mocha-Green ]; then
        python3 <(curl https://raw.githubusercontent.com/catppuccin/ulauncher/main/install.py -fsSL) -f all -a all &>/dev/null
        echo "...Installed Ulauncher Catppuccin themes"
    fi

    # Plank
    if [ ! -d "$HOME"/.local/share/plank ]; then
        mkdir "$HOME"/.local/share/plank
        echo "...Created plank directory"
    fi

    if [ ! -d "$HOME"/.local/share/plank/themes ]; then
        mkdir "$HOME"/.local/share/plank/themes
        echo "...Created plank themes directory"
    fi

    if [ ! -d "$HOME"/.local/share/plank/themes/Catppuccin-mocha ]; then
        mkdir "$HOME"/repos/theming/catppuccin-plank
        git clone https://github.com/catppuccin/plank.git "$HOME"/repos/theming/catppuccin-plank &>/dev/null
        cp -r "$HOME"/repos/theming/catppuccin-plank/src/Catppuccin-mocha "$HOME"/.local/share/plank/themes &>/dev/null
        echo "...Installed Catppuccin plank theme"
    fi

    # Grub
    if [ ! -d /usr/share/grub/themes ]; then
        sudo mkdir /usr/share/grub/themes
        echo "...Created grub themes directory"
    fi

    if [ ! -d /usr/share/grub/themes/catppuccin-mocha-grub-theme ]; then
        mkdir "$HOME"/repos/theming/catppuccin-grub
        git clone https://github.com/catppuccin/grub.git "$HOME"/repos/theming/catppuccin-grub &>/dev/null
        sudo cp -r "$HOME"/repos/theming/catppuccin-grub/src/catppuccin-mocha-grub-theme /usr/share/grub/themes &>/dev/null
        echo "...Installed Catppuccin grub theme to themes directory"
    fi

    grubThemeCheck=$(grep "/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt" </etc/default/grub)
    if [ "$grubThemeCheck" == "" ]; then
        echo "...NOTE: Set grub theme by adding GRUB_THEME=\"/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt\" to /etc/default/grub, then running update-grub"
    fi

    # Wallpapers
    if [ ! -d "$HOME"/Pictures/wallpapers/catppuccin ]; then
        mkdir "$HOME"/Pictures/wallpapers/catppuccin
        mkdir "$HOME"/repos/theming/catppuccin-wallpapers
        git clone https://github.com/Gingeh/wallpapers.git "$HOME"/repos/theming/catppuccin-wallpapers &>/dev/null
        cp -r "$HOME"/repos/theming/catppuccin-wallpapers/*/*.png "$HOME"/Pictures/wallpapers/catppuccin &>/dev/null
        cp -r "$HOME"/repos/theming/catppuccin-wallpapers/*/*.jpg "$HOME"/Pictures/wallpapers/catppuccin &>/dev/null
        echo "...Catppuccin wallpaper pack installed"
    fi

    # Tmux
    if ! grep -Fxq "set -g @plugin 'catppuccin/tmux'" "$HOME"/.tmux.conf.local; then
        echo "NOTE: Set tmux theme by adding the following to .tmux.conf.local: set -g @plugin 'catppuccin/tmux'"
    fi
}

function InstallDebGet {
    echo "TASK: InstallDebGet"

    InstallPackageIfMissing lsb-release

    debGetCheck=$(sudo apt list deb-get 2>/dev/null | grep installed)
    if [ "$debGetCheck" != "" ]; then
        return 0
    fi

    curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get &>/dev/null
    echo "...deb-get installed"
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

    wget -q https://downloads.slack-edge.com/releases/linux/$slackVersion/prod/x64/$filename
    sudo dpkg -i $filename &>/dev/null
    rm $filename
    echo "...Slack installed"
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

    if [ -d "$HOME"/android-studio ]; then
        return 0
    fi

    echo "...Downloading Android Studio"
    wget -q https://redirector.gvt1.com/edgedl/android/studio/ide-zips/$androidStudioVersion/android-studio-$androidStudioVersion-linux.tar.gz
    echo "...Unpacking Android Studio"
    tar -xvzf android-studio-$androidStudioVersion-linux.tar.gz &>/dev/null
    mv android-studio "$HOME"
    rm -f android-studio-$androidStudioVersion-linux.tar.gz
    echo "...Installed Android Studio. Run via CLI and use the in-app option for creating desktop entry"
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
        "openjdk-21-jdk"
    )

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done
}
