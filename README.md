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
4. Install codecs + H264 using docs in the following order:
   - Fedora quick docs for Multimedia
   - Fedora quick docs for OpenH264
   - Fedora Gaming docs for Steam (just line that mentions OpenH264)
   - RPM Fusion docs for Multimedia
5. Install git
6. Clone bootstrap repo
7. Run fedora.sh
8. Move bootstrap directory to repos
9. Reboot, finish setup using dotfiles repo

## Gentoo

1. Follow the Handbook, but do not reboot when it says to
2. Continue through post-reboot portion of handbook and complete remaining steps
3. Make note of anything that shouldn't be done ahead of time (removing
   stage3 tarball, disabling root user, etc.) so we can do it later
4. Install and configure eix
5. Install and configure NetworkManager
6. Install git + vim + neovim, eselect editor, depclean
7. Clone bootstrap repo
8. Run gentoo.sh, proceed until desktop environment and web browser are installed
9. Reboot, continue remaining setup via gentoo.sh
