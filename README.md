# bootstrap

## Debian

1. Ensure apt sources fit the use case
2. Full update of base system to latest using apt
3. Reboot
4. Install git
5. Clone bootstrap repo
6. Edit server flag (optional)
7. Run debian.sh
8. Edit /etc/network/interfaces
9. Move bootstrap directory to repos
10. Reboot, finish setup using dotfiles

## Fedora

1. Install via ISO of desired desktop environment
2. Update system + autoremove + reboot
3. [Enable RPM Fusion repos](https://docs.fedoraproject.org/en-US/quick-docs/rpmfusion-setup/)
4. Install codecs + H264 using both Fedora docs and RPM fusion docs in that order
5. Install git
6. Clone bootstrap repo
7. Run fedora.sh
8. Move bootstrap directory to repos
9. Reboot, finish setup using dotfiles

## Gentoo

1. Follow the Handbook in its entirety, until at a tty logged in as regular user. Before first reboot:
   - Install and configure eix
   - Install and configure NetworkManager, ensure nmtui
2. Ensure dist-kernel, nvidia, USE flags
3. Install git + vim + neovim, eselect editor
4. depclean, reboot
5. Clone bootstrap repo
6. Run gentoo.sh

## TODO

slack and spotify in flatpak installs
consolidate more things after comparing fedora to debian, also fedora and gentoo for aws
version checks at the end, maybe at end of finish script
