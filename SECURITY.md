# Security Policy

## Supported versions

Only the latest release on the [Releases page](https://github.com/drlholloway/sightings/releases)
receives fixes. There are no long-term support branches; upgrade to the newest version before
reporting.

## What counts

Sightings runs entirely on your own machine or phone. It has no accounts, no network calls and
no telemetry, so the interesting surface is small:

- Handling of files the app reads: database backups you restore, `.dcalog` captures you replay,
  CSV it writes.
- The USB protocol layer: anything that could make the app send a firmware, calibration or
  serial-number write to the unit, which it is designed never to do.
- Android: the USB bridge and the intents the app accepts.
- The release pipeline: how builds are produced, signed and published.

Crashes from a malformed frame or file are worth reporting as ordinary bugs unless they lead
to something beyond a crash.

## Reporting a vulnerability

Please do not open a public issue for a security problem. Use GitHub's private reporting
instead: **Security → Report a vulnerability** on the repository, or this link:
https://github.com/drlholloway/sightings/security/advisories/new

Include the version, platform, what you observed and how to reproduce it. A `.dcalog` capture
or a sample file is ideal. You will get an acknowledgement within a week. Fixes ship as a new
release with a credit in the changelog unless you prefer to stay anonymous.

## Dependencies

Dependabot watches the Dart, Gradle and GitHub Actions dependencies weekly and CodeQL scans
the repository on every push. Security fixes that arrive through dependency updates are called
out in `CHANGELOG.md` under the affected release.
