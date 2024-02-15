#!/bin/bash

# Environment variables
source ./.env &>/dev/null

aptUpdated=false

function CheckForPackageAndInstallIfMissing {
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

function CreateReposDirectory {
    echo "TASK: CreateReposDirectory"

    if [ ! -d /home/$username/repos ]; then
        sudo -u $username mkdir /home/$username/repos &>/dev/null
        echo "...Created repos directory"
    fi
}

function InstallCoreUtilities {
    echo "TASK: InstallCoreUtilities"

    packages=("neovim" "zsh" "curl" "wget" "tmux" "htop" "unar" "neofetch" "aptitude")

    for package in "${packages[@]}"; do
        CheckForPackageAndInstallIfMissing "$package"
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

        sudo -u $username git clone https://github.com/gpakosz/.tmux.git $ohMyTmuxPath &>/dev/null
        sudo -u $username ln -s -f $ohMyTmuxPath/.tmux.conf /home/$username/.tmux.conf &>/dev/null
        sudo -u $username cp $ohMyTmuxPath/.tmux.conf.local /home/$username/ &>/dev/null

        echo "...Successfully installed Oh My Tmux"
    fi

    # Ensure Tmux is fully configured, exit if not
    # Check for commented out mouse mode as the check, the default config has this
    if grep -Fxq "#set -g mouse on" /home/$username/.tmux.conf.local; then
        echo "ERROR: Oh My Tmux must be configured, rerun script after configuring"
        return 1
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
    CheckForPackageAndInstallIfMissing linux-headers-amd64

    # non-free firmware
    CheckForPackageAndInstallIfMissing firmware-misc-nonfree

    # Main driver
    CheckForPackageAndInstallIfMissing nvidia-driver
}

function InstallDesktopEnvironment {
    echo "TASK: InstallDesktopEnvironment"

    # Display manager
    CheckForPackageAndInstallIfMissing lightdm

    # Standard MATE + extras
    CheckForPackageAndInstallIfMissing mate-desktop-environment
    CheckForPackageAndInstallIfMissing mate-desktop-environment-extras
    CheckForPackageAndInstallIfMissing xscreensaver

    # Dock
    CheckForPackageAndInstallIfMissing plank

    # App Launcher (requires extra setup)

    # Exit if already installed
    if dpkg-query -W ulauncher &>/dev/null; then
        return 0
    fi

    # Setup keyring using gnupg and export
    CheckForPackageAndInstallIfMissing gnupg
    sudo -u $username gpg --keyserver keyserver.ubuntu.com --recv 0xfaf1020699503176 &>/dev/null
    sudo -u $username gpg --export 0xfaf1020699503176 | sudo tee /usr/share/keyrings/ulauncher-archive-keyring.gpg >/dev/null

    # Add source with exported keyring to sources
    echo "deb [signed-by=/usr/share/keyrings/ulauncher-archive-keyring.gpg] \
          http://ppa.launchpad.net/agornostal/ulauncher/ubuntu jammy main" |
        sudo tee /etc/apt/sources.list.d/ulauncher-jammy.list &>/dev/null

    # Do a manual apt update here so we can get the new source and install package
    # Ensure flag is true if not already
    sudo apt update &>/dev/null
    aptUpdated=true

    # Install now
    CheckForPackageAndInstallIfMissing ulauncher

    # On Sid this sometimes doesn't work and need to manually install dependency
    # Check and error if this happened
    if ! dpkg-query -W ulauncher &>/dev/null; then
        echo "ERROR: ulauncher could not be installed, install manually and rerun script"
        return 1
    fi
}

function InstallFonts {
    echo "TASK: InstallFonts"

    if [ ! -d "/home/$username/.local/share/fonts" ]; then
        sudo -u $username mkdir /home/$username/.local/share/fonts
        echo "...Fonts directory created"
    fi

    # MSFT
    CheckForPackageAndInstallIfMissing ttf-mscorefonts-installer

    # Fira Code + Nerd Font
    CheckForPackageAndInstallIfMissing fonts-firacode

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
    CheckForPackageAndInstallIfMissing fonts-ubuntu

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
    CheckForPackageAndInstallIfMissing fonts-noto-color-emoji
}

function InstallPipewire {
    echo "TASK: InstallPipewire"

    CheckForPackageAndInstallIfMissing pipewire-audio
    CheckForPackageAndInstallIfMissing pavucontrol
}

function InstallFlatpak {
    echo "TASK: InstallFlatpak"

    CheckForPackageAndInstallIfMissing flatpak

    flathubCheck=$(flatpak remotes | grep flathub)
    if [ "$flathubCheck" == "" ]; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
        echo "...Flathub repository added"
    fi
}

function InstallDebGet {
    echo "TASK: InstallDebGet"

    CheckForPackageAndInstallIfMissing lsb-release

    debGetCheck=$(sudo apt list deb-get 2>/dev/null | grep installed)
    if [ "$debGetCheck" == "" ]; then
        curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get &>/dev/null
        echo "...deb-get installed"
    fi

    #flathubCheck=$(flatpak remotes | grep flathub)
    #if [ "$flathubCheck" == "" ]; then
    #    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
    #    echo "...Flathub repository added"
    #fi
}

function InstallAdditionalSoftware {
    echo "TASK: InstallAdditionalSoftware"

    # NetworkManager
    CheckForPackageAndInstallIfMissing network-manager-gnome
    CheckForPackageAndInstallIfMissing network-manager-openvpn-gnome

    # Emacs + Doom dependencies
    CheckForPackageAndInstallIfMissing emacs-gtk
    CheckForPackageAndInstallIfMissing elpa-ligature
    CheckForPackageAndInstallIfMissing ripgrep
    CheckForPackageAndInstallIfMissing fd-find

    # Tiling WM utils
    CheckForPackageAndInstallIfMissing picom
    CheckForPackageAndInstallIfMissing lxappearance
    CheckForPackageAndInstallIfMissing lxsession
    CheckForPackageAndInstallIfMissing nitrogen
    CheckForPackageAndInstallIfMissing volumeicon-alsa
    CheckForPackageAndInstallIfMissing arandr

    # qtile
    CheckForPackageAndInstallIfMissing python-is-python3
    CheckForPackageAndInstallIfMissing python3-pip
    CheckForPackageAndInstallIfMissing pipx
    CheckForPackageAndInstallIfMissing xserver-xorg
    CheckForPackageAndInstallIfMissing xinit
    CheckForPackageAndInstallIfMissing libpangocairo-1.0-0
    CheckForPackageAndInstallIfMissing python3-xcffib
    CheckForPackageAndInstallIfMissing python3-cairocffi
    CheckForPackageAndInstallIfMissing python3-dbus-next

    # Media + Office
    CheckForPackageAndInstallIfMissing vlc
    CheckForPackageAndInstallIfMissing transmission-gtk
    CheckForPackageAndInstallIfMissing obs-studio
    CheckForPackageAndInstallIfMissing libreoffice

    # Misc utils
    CheckForPackageAndInstallIfMissing gparted
    CheckForPackageAndInstallIfMissing copyq
    CheckForPackageAndInstallIfMissing awscli
    CheckForPackageAndInstallIfMissing sshpass
    CheckForPackageAndInstallIfMissing qflipper

    # Game related things
    CheckForPackageAndInstallIfMissing aisleriot
    CheckForPackageAndInstallIfMissing gnome-mines
    CheckForPackageAndInstallIfMissing mgba-qt
    CheckForPackageAndInstallIfMissing lutris
    CheckForPackageAndInstallIfMissing dolphin-emu
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

        CheckForPackageAndInstallIfMissing dotnet-sdk-7.0
        CheckForPackageAndInstallIfMissing dotnet-sdk-8.0
    fi
}

function InstallWebBrowsers {
    echo "TASK: InstallWebBrowsers"

    CheckForPackageAndInstallIfMissing firefox

    # Ungoogled Chromium
    chromiumCheck=$(sudo apt list ungoogled-chromium 2>/dev/null | grep installed)
    if [ "$chromiumCheck" == "" ]; then
        echo 'deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/Debian_Sid/ /' | sudo tee /etc/apt/sources.list.d/home:ungoogled_chromium.list &>/dev/null
        curl -fsSL https://download.opensuse.org/repositories/home:ungoogled_chromium/Debian_Sid/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_ungoogled_chromium.gpg >/dev/null

        sudo apt update &>/dev/null
        aptUpdated=true

        CheckForPackageAndInstallIfMissing ungoogled-chromium
    fi

    # LibreWolf
    librewolfCheck=$(sudo apt list librewolf 2>/dev/null | grep installed)
    if [ "$librewolfCheck" == "" ]; then
        CheckForPackageAndInstallIfMissing apt-transport-https
        CheckForPackageAndInstallIfMissing ca-certificates

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

        CheckForPackageAndInstallIfMissing librewolf
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

        CheckForPackageAndInstallIfMissing spotify-client
    fi
}

function InstallOhMyZsh {
    echo "TASK: InstallOhMyZsh"

    if [ ! -d "/home/$username/.oh-my-zsh" ]; then
        echo "...Installing Oh My Zsh, you will be dropped into a new zsh session at the end"
        sudo -u $username sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &>/dev/null
    fi
}
