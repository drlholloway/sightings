#!/bin/sh
# Wraps the Flutter Linux release bundle as an AppImage.
#   packaging/appimage/build-appimage.sh <bundle dir> <version> [output dir]
# Needs appimagetool on PATH (or APPIMAGETOOL pointing at it). libusb-1.0 is
# copied in from the build host so the image runs on systems without it; GTK 3
# is expected from the host, as is usual for Flutter AppImages.
set -eu
BUNDLE="$1"; VERSION="$2"; OUT="${3:-.}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TOOL="${APPIMAGETOOL:-appimagetool}"
APPDIR="$(mktemp -d)/Sightings.AppDir"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/512x512/apps" "$APPDIR/usr/share/metainfo"
cp -r "$BUNDLE/." "$APPDIR/usr/bin/"
LIBUSB="$(ldconfig -p | awk '/libusb-1.0.so.0 /{print $NF; exit}')"
if [ -n "$LIBUSB" ]; then cp -L "$LIBUSB" "$APPDIR/usr/lib/"; else echo "warning: libusb-1.0.so.0 not found on the build host; not bundled" >&2; fi
echo "AppDir libs:"; ls -la "$APPDIR/usr/lib"
install -m755 "$ROOT/packaging/appimage/AppRun" "$APPDIR/AppRun"
# Desktop file, icon and metainfo share the Flatpak's app id so AppStream
# tools can match them (appimagetool looks for <desktop id>.appdata.xml).
ID=dev.laneholloway.Sightings
install -m644 "$ROOT/packaging/appimage/$ID.desktop" "$APPDIR/usr/share/applications/$ID.desktop"
install -m644 "$ROOT/packaging/appimage/$ID.desktop" "$APPDIR/$ID.desktop"
install -m644 "$ROOT/apps/workbench/assets/icon/icon_512.png" "$APPDIR/usr/share/icons/hicolor/512x512/apps/$ID.png"
install -m644 "$ROOT/apps/workbench/assets/icon/icon_512.png" "$APPDIR/$ID.png"
install -m644 "$ROOT/packaging/flatpak/$ID.metainfo.xml" "$APPDIR/usr/share/metainfo/$ID.appdata.xml"
install -m644 "$ROOT/packaging/linux/60-dca75.rules" "$APPDIR/60-dca75.rules"
mkdir -p "$OUT"
# Embedded update information lets AppImageUpdate fetch the newest release;
# appimagetool writes the matching .zsync next to the image, and both are
# published with the release.
NAME="Sightings-$VERSION-x86_64.AppImage"
UPDATE="gh-releases-zsync|drlholloway|sightings|latest|Sightings-*x86_64.AppImage.zsync"
cd "$OUT"
ARCH=x86_64 VERSION="$VERSION" "$TOOL" --appimage-extract-and-run -n -u "$UPDATE" "$APPDIR" "$NAME" 2>/dev/null \
  || ARCH=x86_64 VERSION="$VERSION" "$TOOL" -n -u "$UPDATE" "$APPDIR" "$NAME"
ls -la "$NAME" "$NAME.zsync"
