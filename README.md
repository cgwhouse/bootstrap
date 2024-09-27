# bootstrap

Welcome to Flavortown

```bash
bash <(curl -s https://raw.githubusercontent.com/cgwhouse/bootstrap/refs/heads/bootstrap2/bootstrap.sh)
```

## Pre-Bootstrap Checklists

### Fedora

1. Update system with
   `sudo dnf distro-sync --refresh && sudo dnf autoremove` and reboot
2. Enable and configure RPM Fusion repos:

   ```bash
   sudo dnf install \
   https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
   https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

   sudo dnf config-manager --enable fedora-cisco-openh264
   ```

3. If applicable, deal with [NVIDIA graphics](https://rpmfusion.org/Howto/NVIDIA)
4. Enable proprietary codecs, then apply [Firefox config changes](https://docs.fedoraproject.org/en-US/quick-docs/openh264/#_firefox_config_changes):

   ```bash
   sudo dnf group install Multimedia
   #sudo dnf install gstreamer1-plugin-openh264 mozilla-openh264
   sudo dnf swap ffmpeg-free ffmpeg --allowerasing
   sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
   sudo dnf update @sound-and-video

   # Intel
   sudo dnf install intel-media-driver

   # AMD
   sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
   sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
   sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
   sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686

   # NVIDIA
   sudo dnf install libva-nvidia-driver.{i686,x86_64}
   ```

### Gentoo

1. Follow the Handbook.
   When it says to reboot, before doing so, install and configure eix.
2. After completing the Handbook, do the following in order using Gentoo Wiki:
   - desktop environment (`vaapi vdpau -gnome-online-accounts -kde -plasma -telemetry`)
   - audio (`pipewire`)
   - Firefox bin

## Post-Bootstrap Checklist

(probably want to link to this as another document, we could copy one onto the desktop for ourselves)
this is the new CONFIG.md

- Re-run script if needed to pick up any remaining tasks
- After getting clean output, reboot
- Alacritty config to `$HOME/.config/alacritty/alacritty.toml`
- Ulauncher on startup
- Look at `appimages` directory + browser bookmarks to get any manual / additional stuff
