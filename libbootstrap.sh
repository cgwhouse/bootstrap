#!/bin/bash

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

function ConfigureTmux {
    echo "TASK: ConfigureTmux"

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

function InstallNvm {
    echo "TASK: InstallNvm"

    if [ ! -d "$HOME"/.nvm ]; then
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash &>/dev/null
        echo "...nvm installed"
    fi
}

function ConfigureZsh {
    echo "TASK: ConfigureZsh"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "...Installing Oh My Zsh, you will be dropped into a new zsh session at the end"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

function InstallFontsCommon {
    if [ ! -d "$HOME/.local/share/fonts" ]; then
        mkdir "$HOME"/.local/share/fonts
        echo "...Fonts directory created"
    fi

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
}

function DownloadThemingCommon {
    # GTK + icons
    if [ ! -d "$HOME"/.themes ]; then
        mkdir "$HOME"/.themes &>/dev/null
        echo "...Created .themes directory"
    fi

    accentColors=(
        "Blue"
        "Flamingo"
        "Green"
        "Lavender"
        "Maroon"
        "Mauve"
        "Peach"
        "Pink"
        "Red"
        "Rosewater"
        "Sapphire"
        "Sky"
        "Teal"
        "Yellow"
    )

    # This is no longer what it is called
    # TODO: replace the old one with the new one if old one is detected
    # leave a note that it can be removed after sometime

    for accentColor in "${accentColors[@]}"; do
        if [ ! -d "$HOME"/.themes/Catppuccin-Mocha-Standard-"$accentColor"-Dark ]; then
            wget -q https://github.com/catppuccin/gtk/releases/latest/download/Catppuccin-Mocha-Standard-"$accentColor"-Dark.zip
            unar -d Catppuccin-Mocha-Standard-"$accentColor"-Dark.zip &>/dev/null
            mv Catppuccin-Mocha-Standard-"$accentColor"-Dark/Catppuccin-Mocha-Standard-"$accentColor"-Dark "$HOME"/.themes &>/dev/null
            rm -rf Catppuccin-Mocha-Standard-"$accentColor"-Dark &>/dev/null
            rm -f Catppuccin-Mocha-Standard-"$accentColor"-Dark.zip &>/dev/null
            echo "...Installed Catppuccin GTK Mocha $accentColor theme"
        fi
    done

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

function DownloadPlankThemeCommon {
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
}

function CheckVirtManagerCompatibility {
    lscpuCheck=$(lscpu | grep VT-x)
    if [ "$lscpuCheck" == "" ]; then
        return 1
    fi

    uname=$(uname -r)
    zgrepCheck=$(zgrep CONFIG_KVM /boot/config-"$uname" | grep "CONFIG_KVM_GUEST=y")
    if [ "$zgrepCheck" == "" ]; then
        return 1
    fi
}

function PerformCommonVirtManagerChecks {
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

function EnableFlathubRepo {
    flathubCheck=$(sudo flatpak remotes | grep flathub)
    if [ "$flathubCheck" != "" ]; then
        return 0
    fi

    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
    echo "...Flathub repository added"
}

function PerformNvidiaHardwareCheck {
    nvidiaHardwareCheck=$(lspci | grep NVIDIA | awk -F: '{print $NF}')
    if [ "$nvidiaHardwareCheck" == "" ]; then
        return 1
    fi
}

function InstallAwsCommon {
    if [ ! -f "/usr/local/bin/aws" ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &>/dev/null
        unzip awscliv2.zip &>/dev/null
        sudo ./aws/install &>/dev/null
        rm -f awscliv2.zip
        rm -rf aws
        echo "...Installed AWS CLI"
    fi
}
