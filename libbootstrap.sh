#!/bin/bash

# Environment variables
source ./.env &>/dev/null

aptUpdated=false

# Versions of a couple things that are manual
doctlVersion="1.104.0"
slackVersion="4.36.140"

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

    if [ ! -d /home/$username/repos ]; then
        mkdir /home/$username/repos &>/dev/null
        echo "...Created repos directory"
    fi

    if [ ! -d /home/$username/repos/theming ]; then
        mkdir /home/$username/repos/theming &>/dev/null
        echo "...Created theming directory"
    fi

    if [ ! -d /home/$username/Pictures/wallpapers ]; then
        mkdir /home/$username/Pictures/wallpapers &>/dev/null
        echo "...Created wallpapers directory"
    fi
}

function InstallCoreUtilities {
    echo "TASK: InstallCoreUtilities"

    packages=("neovim" "zsh" "curl" "wget" "tmux" "htop" "unar" "neofetch" "aptitude" "apt-transport-https")

    for package in "${packages[@]}"; do
        InstallPackageIfMissing "$package"
    done
}

function ConfigureCoreUtilities {
    echo "TASK: ConfigureCoreUtilities"

    # Ensure zsh is default shell for user
    userShell=$(getent passwd $username | awk -F: '{print $NF}')
    if [ "$userShell" != "/usr/bin/zsh" ]; then
        echo "...Changing default shell to zsh"
        sudo usermod --shell /usr/bin/zsh $username &>/dev/null
        echo "...Default shell changed to zsh"
    fi

    # Oh My Tmux
    ohMyTmuxPath="/home/$username/.tmux"
    if [ ! -d $ohMyTmuxPath ]; then
        echo "...Installing Oh My Tmux"

        git clone https://github.com/gpakosz/.tmux.git $ohMyTmuxPath &>/dev/null
        ln -s -f $ohMyTmuxPath/.tmux.conf /home/$username/.tmux.conf &>/dev/null
        cp $ohMyTmuxPath/.tmux.conf.local /home/$username/ &>/dev/null

        echo "...Successfully installed Oh My Tmux"
    fi

    # Ensure Tmux is fully configured, exit if not
    # Check for commented out mouse mode as the check, the default config has this
    if grep -Fxq "#set -g mouse on" /home/$username/.tmux.conf.local; then
        echo "...WARNING: Oh My Tmux still needs to be configured"
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
    if dpkg-query -W ulauncher &>/dev/null; then
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

function InstallFonts {
    echo "TASK: InstallFonts"

    if [ ! -d "/home/$username/.local/share/fonts" ]; then
        mkdir /home/$username/.local/share/fonts
        echo "...Fonts directory created"
    fi

    # MSFT
    InstallPackageIfMissing ttf-mscorefonts-installer

    # Fira Code + Nerd Font
    InstallPackageIfMissing fonts-firacode

    firaCodeNerdFontCheck="/home/$username/.local/share/fonts/FiraCodeNerdFont-Regular.ttf"
    if [ ! -f $firaCodeNerdFontCheck ]; then
        echo "...Installing FiraCode Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -o fira.zip &>/dev/null
        unar -d fira.zip &>/dev/null
        cp fira/*.ttf /home/$username/.local/share/fonts &>/dev/null
        rm -r fira &>/dev/null
        rm fira.zip &>/dev/null
        echo "...FiraCode Nerd Font installed"
    fi

    # Ubuntu + Nerd Font + UbuntuMono Nerd Font
    InstallPackageIfMissing fonts-ubuntu

    ubuntuNerdFontCheck="/home/$username/.local/share/fonts/UbuntuNerdFont-Regular.ttf"
    if [ ! -f $ubuntuNerdFontCheck ]; then
        echo "...Installing Ubuntu Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Ubuntu.zip -o ubuntu.zip &>/dev/null
        unar -d ubuntu.zip &>/dev/null
        cp ubuntu/*.ttf /home/$username/.local/share/fonts &>/dev/null
        rm -r ubuntu &>/dev/null
        rm ubuntu.zip &>/dev/null
        echo "...Ubuntu Nerd Font installed"
    fi

    ubuntuMonoNerdFontCheck="/home/$username/.local/share/fonts/UbuntuMonoNerdFont-Regular.ttf"
    if [ ! -f $ubuntuMonoNerdFontCheck ]; then
        echo "...Installing UbuntuMono Nerd Font"
        curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip -o ubuntumono.zip &>/dev/null
        unar -d ubuntumono.zip &>/dev/null
        cp ubuntumono/*.ttf /home/$username/.local/share/fonts &>/dev/null
        rm -r ubuntumono &>/dev/null
        rm ubuntumono.zip &>/dev/null
        echo "...UbuntuMono Nerd Font installed"
    fi

    # Noto Emoji
    InstallPackageIfMissing fonts-noto-color-emoji
}

function InstallPipewire {
    echo "TASK: InstallPipewire"

    InstallPackageIfMissing pipewire-audio
    InstallPackageIfMissing pavucontrol
}

function InstallFlatpak {
    echo "TASK: InstallFlatpak"

    InstallPackageIfMissing flatpak

    flathubCheck=$(flatpak remotes | grep flathub)
    if [ "$flathubCheck" == "" ]; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
        echo "...Flathub repository added"
    fi
}

function InstallDebGet {
    echo "TASK: InstallDebGet"

    InstallPackageIfMissing lsb-release

    debGetCheck=$(sudo apt list deb-get 2>/dev/null | grep installed)
    if [ "$debGetCheck" == "" ]; then
        curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get &>/dev/null
        echo "...deb-get installed"
    fi
}

function InstallDotNetCore {
    echo "TASK: InstallDotNetCore"

    dotnetCheck=$(sudo apt list dotnet-sdk-8.0 2>/dev/null | grep installed)
    if [ "$dotnetCheck" == "" ]; then
        wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb &>/dev/null
        rm packages-microsoft-prod.deb &>/dev/null

        sudo apt update &>/dev/null
        aptUpdated=true

        InstallPackageIfMissing dotnet-sdk-7.0
        InstallPackageIfMissing dotnet-sdk-8.0
    fi
}

function InstallNvm {
    echo "TASK: InstallNvm"

    if [ ! -d /home/$username/.nvm ]; then
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash &>/dev/null
        echo "...nvm installed"
    fi
}

function InstallVisualStudioCode {
    echo "TASK: InstallVisualStudioCode"

    vscodeCheck=$(sudo apt list code 2>/dev/null | grep installed)
    if [ "$vscodeCheck" == "" ]; then
        InstallPackageIfMissing gpg

        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg &>/dev/null

        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" >/etc/apt/sources.list.d/vscode.list

        rm -f packages.microsoft.gpg

        sudo apt update &>/dev/null
        aptUpdated=true

        InstallPackageIfMissing code
    fi
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
    if [ "$spotifyCheck" == "" ]; then
        curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg &>/dev/null
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list &>/dev/null

        sudo apt update &>/dev/null
        aptUpdated=true

        InstallPackageIfMissing spotify-client
    fi
}

function InstallDoctl {
    echo "TASK: InstallDoctl"

    filename="doctl-$doctlVersion-linux-amd64.tar.gz"

    if ! (hash doctl 2>/dev/null); then
        wget -q https://github.com/digitalocean/doctl/releases/latest/download/$filename
        tar xf $filename &>/dev/null
        sudo mv doctl /usr/local/bin
        rm -f $filename
        echo "...doctl installed"
    fi
}

function InstallSlack {
    echo "TASK: InstallSlack"

    filename="slack-desktop-$slackVersion-amd64.deb"

    slackCheck=$(sudo apt list slack-desktop 2>/dev/null | grep installed)
    if [ "$slackCheck" == "" ]; then
        wget -q https://downloads.slack-edge.com/releases/linux/$slackVersion/prod/x64/$filename
        sudo dpkg -i $filename &>/dev/null
        rm $filename
        echo "...Slack installed"
    fi
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

    InstallPackageIfMissing qemu-system-x86
    InstallPackageIfMissing libvirt-daemon-system
    InstallPackageIfMissing virtinst
    InstallPackageIfMissing virt-manager
    InstallPackageIfMissing virt-viewer
    InstallPackageIfMissing ovmf
    InstallPackageIfMissing swtpm
    InstallPackageIfMissing qemu-utils
    InstallPackageIfMissing guestfs-tools
    InstallPackageIfMissing libosinfo-bin
    InstallPackageIfMissing tuned

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
    groupCheck=$(groups $username | grep libvirt)
    if [ "$groupCheck" == "" ]; then
        sudo usermod -aG libvirt $username &>/dev/null
        echo "...User added to libvirt group"
    fi
}

function DownloadTheming {
    echo "TASK: DownloadTheming"

    # GTK + icons
    InstallPackageIfMissing gnome-themes-extra

    if [ ! -d /home/$username/.themes ]; then
        mkdir /home/$username/.themes &>/dev/null
        echo "...Created .themes directory"
    fi

    if [ ! -d /home/$username/.themes/Catppuccin-Mocha-Standard-Green-Dark ]; then
        wget -q https://github.com/catppuccin/gtk/releases/latest/download/Catppuccin-Mocha-Standard-Green-Dark.zip
        unar -d Catppuccin-Mocha-Standard-Green-Dark.zip &>/dev/null
        mv Catppuccin-Mocha-Standard-Green-Dark/Catppuccin-Mocha-Standard-Green-Dark /home/$username/.themes &>/dev/null
        rm -rf Catppuccin-Mocha-Standard-Green-Dark &>/dev/null
        rm -f Catppuccin-Mocha-Standard-Green-Dark.zip &>/dev/null
        echo "...Installed Catppuccin GTK theme"
    fi

    if [ ! -d /home/$username/.local/share/icons ]; then
        mkdir /home/$username/.local/share/icons &>/dev/null
        echo "...Created icons directory"
    fi

    if [ ! -d /home/$username/.local/share/icons/Tela-circle-dark ]; then
        mkdir /home/$username/repos/theming/Tela-circle-dark
        git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git /home/$username/repos/theming/Tela-circle-dark &>/dev/null
        /home/$username/repos/theming/Tela-circle-dark/install.sh -a -c -d /home/$username/.local/share/icons &>/dev/null
        echo "...Installed Tela-circle icon themes"
    fi

    # Ulauncher
    if [ ! -d /home/$username/.config/ulauncher/user-themes/Catppuccin-Mocha-Green ]; then
        python3 <(curl https://raw.githubusercontent.com/catppuccin/ulauncher/main/install.py -fsSL) -f all -a all &>/dev/null
        echo "...Installed Ulauncher Catppuccin themes"
    fi

    # Plank
    if [ ! -d /home/$username/.local/share/plank ]; then
        mkdir /home/$username/.local/share/plank
        echo "...Created plank directory"
    fi

    if [ ! -d /home/$username/.local/share/plank/themes ]; then
        mkdir /home/$username/.local/share/plank/themes
        echo "...Created plank themes directory"
    fi

    if [ ! -d /home/$username/.local/share/plank/themes/Catppuccin-mocha ]; then
        mkdir /home/$username/repos/theming/catppuccin-plank
        git clone https://github.com/catppuccin/plank.git /home/$username/repos/theming/catppuccin-plank &>/dev/null
        cp -r /home/$username/repos/theming/catppuccin-plank/src/Catppuccin-mocha /home/$username/.local/share/plank/themes &>/dev/null
        echo "...Installed Catppuccin plank theme"
    fi

    # Grub
    if [ ! -d /usr/share/grub/themes ]; then
        sudo mkdir /usr/share/grub/themes
        echo "...Created grub themes directory"
    fi

    if [ ! -d /usr/share/grub/themes/catppuccin-mocha-grub-theme ]; then
        mkdir /home/$username/repos/theming/catppuccin-grub
        git clone https://github.com/catppuccin/grub.git /home/$username/repos/theming/catppuccin-grub &>/dev/null
        sudo cp -r /home/$username/repos/theming/catppuccin-grub/src/catppuccin-mocha-grub-theme /usr/share/grub/themes &>/dev/null
        echo "...Installed Catppuccin grub theme to themes directory"
    fi

    grubThemeCheck=$(grep "/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt" </etc/default/grub)
    if [ "$grubThemeCheck" == "" ]; then
        echo "...NOTE: Set grub theme by adding GRUB_THEME=\"/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt\" to /etc/default/grub, then running update-grub"
    fi

    # Wallpapers
    if [ ! -d /home/$username/Pictures/wallpapers/catppuccin ]; then
        mkdir /home/$username/Pictures/wallpapers/catppuccin
        mkdir /home/$username/repos/theming/catppuccin-wallpapers
        git clone https://github.com/Gingeh/wallpapers.git /home/$username/repos/theming/catppuccin-wallpapers &>/dev/null
        cp -r /home/$username/repos/theming/catppuccin-wallpapers/*/*.png /home/$username/Pictures/wallpapers/catppuccin &>/dev/null
        cp -r /home/$username/repos/theming/catppuccin-wallpapers/*/*.jpg /home/$username/Pictures/wallpapers/catppuccin &>/dev/null
        echo "...Catppuccin wallpaper pack installed"
    fi

    # Tmux
    if ! grep -Fxq "set -g @plugin 'catppuccin/tmux'" /home/$username/.tmux.conf.local; then
        echo "NOTE: Set tmux theme by adding the following to .tmux.conf.local: set -g @plugin 'catppuccin/tmux'"
    fi
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

    # NetworkManager
    InstallPackageIfMissing network-manager-gnome
    InstallPackageIfMissing network-manager-openvpn-gnome

    # Emacs + Doom dependencies
    InstallPackageIfMissing emacs-gtk
    InstallPackageIfMissing elpa-ligature
    InstallPackageIfMissing ripgrep
    InstallPackageIfMissing fd-find

    # Tiling WM utils
    InstallPackageIfMissing picom
    InstallPackageIfMissing lxappearance
    InstallPackageIfMissing lxsession
    InstallPackageIfMissing nitrogen
    InstallPackageIfMissing volumeicon-alsa
    InstallPackageIfMissing arandr

    # qtile
    InstallPackageIfMissing python-is-python3
    InstallPackageIfMissing python3-pip
    InstallPackageIfMissing pipx
    InstallPackageIfMissing xserver-xorg
    InstallPackageIfMissing xinit
    InstallPackageIfMissing libpangocairo-1.0-0
    InstallPackageIfMissing python3-xcffib
    InstallPackageIfMissing python3-cairocffi
    InstallPackageIfMissing python3-dbus-next

    # Media + Office
    InstallPackageIfMissing vlc
    InstallPackageIfMissing transmission-gtk
    InstallPackageIfMissing obs-studio
    InstallPackageIfMissing libreoffice

    # Misc utils
    InstallPackageIfMissing gparted
    InstallPackageIfMissing copyq
    InstallPackageIfMissing awscli
    InstallPackageIfMissing sshpass
    InstallPackageIfMissing qflipper

    # Game related things
    InstallPackageIfMissing aisleriot
    InstallPackageIfMissing gnome-mines
    InstallPackageIfMissing mgba-qt
    InstallPackageIfMissing lutris
    InstallPackageIfMissing dolphin-emu
}

function InstallOhMyZsh {
    echo "TASK: InstallOhMyZsh"

    if [ ! -d "/home/$username/.oh-my-zsh" ]; then
        echo "...Installing Oh My Zsh, you will be dropped into a new zsh session at the end"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &>/dev/null
    fi
}
