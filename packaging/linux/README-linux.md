# Sightings for Linux (x86-64)

Companion app for the Peak Atlas DCA75 semiconductor analyzer.

This is the plain tarball build. A Flatpak bundle (`sightings-linux-x64-<version>.flatpak`) is
also on the Releases page; it brings its own GTK and libusb and installs with
`flatpak install --user <file>`. The udev rule below is needed either way.

## Requirements

- A 64-bit Intel/AMD Linux with GTK 3 and `libusb-1.0` installed
  (Debian/Ubuntu: `sudo apt install libgtk-3-0 libusb-1.0-0`; Fedora: `sudo dnf install gtk3 libusb1`).

## Install

1. Extract the archive anywhere, e.g. `~/Apps/sightings`.
2. Let your user open the DCA75 without root (once):

       sudo cp 60-dca75.rules /etc/udev/rules.d/
       sudo udevadm control --reload && sudo udevadm trigger

3. Plug in the unit (or unplug and replug it), then run `./workbench`.

The app connects automatically when a unit is present. Readings are stored in
`~/.local/share/dev.laneholloway.workbench/`.

## If it shows "access denied"

The udev rule is not active for this plug-in. Re-run step 2 and replug the unit.

Not affiliated with Peak Electronic Design Ltd. See the license in Settings.
