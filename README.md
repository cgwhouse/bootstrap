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

1. Follow the Handbook in its entirety, until at a tty logged in as regular user
2. Ensure dist-kernel and nvidia USE flags
3. Install git + vim + neovim, eselect editor
4. Setup eix via the wiki
5. depclean, reboot
6. Clone bootstrap repo
7. Run gentoo.sh
