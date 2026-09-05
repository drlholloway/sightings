#!/bin/bash
# Copy libusb-1.0 into a built .app so the release does not depend on Homebrew.
# Usage: packaging/macos/bundle-libusb.sh path/to/workbench.app
set -euo pipefail
APP="${1:?path to .app}"
SRC="${LIBUSB_DYLIB:-/opt/homebrew/lib/libusb-1.0.0.dylib}"
DEST="$APP/Contents/Frameworks/libusb-1.0.0.dylib"
mkdir -p "$(dirname "$DEST")"
cp "$SRC" "$DEST"
chmod 644 "$DEST"
install_name_tool -id "@rpath/libusb-1.0.0.dylib" "$DEST"
echo "bundled $SRC -> $DEST"
echo "sign it together with the app: codesign --force --sign 'Developer ID Application: …' --options runtime \"$DEST\""
