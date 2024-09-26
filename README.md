# bootstrap

Welcome to Flavortown

```bash
bash <(curl -s https://raw.githubusercontent.com/cgwhouse/bootstrap/refs/heads/bootstrap2/bootstrap.sh)
```

## Pre-Bootstrap Checklists

### Debian

1. Install `curl`

### Fedora

1. Update system and reboot
2. Enable RPM Fusion repos:

   ```bash
   sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

   sudo dnf config-manager --enable fedora-cisco-openh264
   ```

3. Enable proprietary codecs:

   ```bash
   sudo dnf group install Multimedia
   sudo dnf install gstreamer1-plugin-openh264 mozilla-openh264
   ```

   Apply [Firefox config changes](https://docs.fedoraproject.org/en-US/quick-docs/openh264/#_firefox_config_changes)

- Fedora quick docs for OpenH264
- RPM Fusion docs for Multimedia

### Gentoo

1. Follow the Handbook.
   When it says to reboot, before doing so, install and configure eix.
2. After completing the Handbook, do the following in order using Gentoo Wiki:
   - desktop environment (`vaapi vdpau -gnome-online-accounts -kde -plasma -telemetry`)
   - audio (`pipewire`)
   - web browser
3. After installing and spot-checking the above items, clone this repo
4. Run gentoo.sh

## Post-Bootstrap Checklist

(probably want to link to this as another document, we could copy one onto the desktop for ourselves)
this is the new CONFIG.md

- Re-run script if needed to pick up any remaining tasks
- After getting clean output, reboot
