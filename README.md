# bootstrap

## Debian

1. Update apt sources (optional)
2. Full update of base system to latest using apt
3. Reboot
4. Install git
5. Clone bootstrap repo
6. Edit server flag (optional)
7. Run debian.sh
8. Edit /etc/network/interfaces
9. Move bootstrap directory to repos
10. Reboot, finish setup using dotfiles

## Gentoo

1. Follow the Handbook in its entirety, until at a tty logged in as regular user. Before first reboot to tty:
   - Install and configure eix
   - Install and configure NetworkManager with the tools USE flag for nm-tui
2. Ensure dist-kernel, nvidia, networkmanager USE flags
3. Install git + vim + neovim, eselect editor
4. depclean, reboot
5. Clone bootstrap repo
6. Run gentoo.sh
