# Sightings (DCA75 Workbench) task runner (https://github.com/casey/just). `just --list`.

set shell := ["bash", "-cu"]
export PATH := "/opt/homebrew/bin:" + env_var("PATH")

packages := "packages/dca75_protocol packages/dca75_transport packages/dca75_device packages/dca75_circuits packages/dca75_store tools/dca75_cli"

# fetch dependencies for the whole workspace
get:
    dart pub get

# static analysis everywhere
analyze:
    dart analyze
    cd apps/workbench && flutter analyze

# run every test suite
test:
    for p in {{packages}}; do (cd $p && dart test); done
    cd apps/workbench && flutter test

# regenerate drift code
codegen:
    cd packages/dca75_store && dart run build_runner build --delete-conflicting-outputs

format:
    dart format .

run-macos:
    cd apps/workbench && flutter run -d macos

run-linux:
    cd apps/workbench && flutter run -d linux

run-android:
    cd apps/workbench && flutter run -d android

build-macos:
    cd apps/workbench && flutter build macos --release
    ./packaging/macos/bundle-libusb.sh apps/workbench/build/macos/Build/Products/Release/Sightings.app

build-linux:
    cd apps/workbench && flutter build linux --release

# Linux only: wrap the release bundle as an AppImage (needs appimagetool on PATH)
build-appimage VERSION: build-linux
    ./packaging/appimage/build-appimage.sh apps/workbench/build/linux/x64/release/bundle {{VERSION}} dist

build-apk:
    cd apps/workbench && flutter build apk --release

# talk to a plugged-in unit from the terminal
probe *ARGS:
    cd tools/dca75_cli && dart run bin/dca75_cli.dart probe {{ARGS}}

identify *ARGS:
    cd tools/dca75_cli && dart run bin/dca75_cli.dart identify {{ARGS}}

bench *ARGS:
    cd tools/dca75_cli && dart run bin/dca75_cli.dart bench {{ARGS}}
