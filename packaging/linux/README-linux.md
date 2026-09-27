# Sightings for Linux (x86-64)

Companion app for the Peak Atlas DCA75 semiconductor analyzer.

This is the plain tarball build. The Releases page also has an AppImage
(`sightings-linux-x64-<version>.AppImage`: make it executable and run it; libusb is bundled)
and a Flatpak bundle (`sightings-linux-x64-<version>.flatpak`: brings its own GTK and libusb,
installs with `flatpak install --user <file>`). The udev rule below is needed in every case; the AppImage and Flatpak don't include a
copy you can reach, so use the one-line command under "access denied" below or download
`60-dca75.rules` from the release.

## Requirements

- A 64-bit Intel/AMD Linux from 2022 or later (GLib 2.72+: Ubuntu 22.04, Debian 12, Mint 21 or newer) with GTK 3 and `libusb-1.0` installed
  (Debian/Ubuntu: `sudo apt install libgtk-3-0 libusb-1.0-0`; Fedora: `sudo dnf install gtk3 libusb1`).

## Install

1. Extract the archive anywhere, e.g. `~/Apps/sightings`.
2. Let your user open the DCA75 without root (once). From the extracted folder:

       sudo cp 60-dca75.rules /etc/udev/rules.d/
       sudo udevadm control --reload && sudo udevadm trigger

3. Plug in the unit (or unplug and replug it), then run `./workbench`.

The app connects automatically when a unit is present. Readings are stored in
`~/.local/share/dev.laneholloway.workbench/`.

## If it shows "access denied"

The app can see the unit but may not open it. Work through these in order:

1. **Replug the unit.** The rule applies when the device is plugged in, not to a unit that
   was already connected before you installed it.
2. **Check the rule is installed:** `cat /etc/udev/rules.d/60-dca75.rules` should print the
   `SUBSYSTEM=="usb", ATTR{idVendor}=="04d8"...` line. If it doesn't, re-run step 2. No rules
   file to hand (AppImage or Flatpak)? This one command writes it and reloads udev:

       echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04d8", ATTR{idProduct}=="f8ca", MODE="0660", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/60-dca75.rules >/dev/null && sudo udevadm control --reload && sudo udevadm trigger

   The same command is in the app under Settings → Linux USB access, with a copy button.
3. **Check the permissions took effect.** `lsusb -d 04d8:f8ca` shows the bus and device
   numbers, e.g. `Bus 001 Device 007`. Then `getfacl /dev/bus/usb/001/007` should list
   `user:<you>:rw-`.
4. **No `user:<you>` entry?** `TAG+="uaccess"` grants access only to the user logged in at the
   machine's own screen (the active local seat). Over SSH, in a remote desktop, or on a
   system without systemd-logind, use a group instead: change the end of the rule to
   `MODE="0660", GROUP="plugdev"`, run `sudo usermod -aG plugdev $USER`, log out and back in,
   reload udev and replug. (Create the group with `sudo groupadd plugdev` if it doesn't exist.)

The rule always goes on the host system, including for the Flatpak build; the sandbox
can't install it for you.

Not affiliated with Peak Electronic Design Ltd. See the license in Settings.
