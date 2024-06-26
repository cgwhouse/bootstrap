# bootstrap

The goal of these scripts is to quickly get up and running on a fresh
installation of one of the following:

- Debian
- Fedora
- Gentoo
- Arch

_Because Arch and Gentoo are meant to be installed with care / manually, the
scripts for these two are basically just over-engineered checklists._

## Debian

1. Install via net installer, deselect all tasks for minimal installation
2. If using on the desktop, update apt sources to Testing, then add Unstable
   packages with lower priority. Update apt sources, then update system and reboot
3. Install git and clone this repo
4. Set optional flag in debian.sh:
   - If headless environment is intended: `server=true`
5. Run debian.sh
6. Move bootstrap directory to repos
7. Reboot

## Fedora

1. Install via ISO of desired desktop environment
2. Update system and reboot
3. [Enable RPM Fusion repos](https://docs.fedoraproject.org/en-US/quick-docs/rpmfusion-setup/)
4. Install codecs + H264 using docs in the following order:
   - Fedora quick docs for Multimedia
   - Fedora quick docs for OpenH264
   - Fedora Gaming docs for Steam (just line that mentions OpenH264)
   - RPM Fusion docs for Multimedia
5. Install git and clone this repo
6. Set optional flag in fedora.sh:
   - If work environment is intended: `work=true`
7. Run fedora.sh
8. Move bootstrap directory to repos
9. Reboot

## Gentoo

1. Follow the Handbook, but do not reboot when it says to
2. Continue through post-reboot portion of handbook and complete remaining steps
3. Make note of anything that shouldn't be done ahead of time (removing
   stage3 tarball, disabling root user, etc.) so we can do it later
4. Install and configure eix
5. Install and configure NetworkManager
6. Install git + vim + neovim, eselect editor, depclean
7. Clone this repo
8. Run gentoo.sh, proceed until desktop environment and web browser are installed
9. Reboot, continue remaining setup via gentoo.sh

## Arch

1. Under construction
