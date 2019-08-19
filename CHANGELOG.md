# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Bootstrapping script for installing on top of Ubuntu 18.04.2
- `KIOSK_OPTS` environment variable for adding options to some kiosk-browser based exhibits 
- BASH scripts for  La La Lab exhibits
- Support for immutable root file system
- Realtime permissions for `audio` group
- Disable auto updates and notifications
- `compton` compositor to prevent screen tearing
- Hostname assignment based on sha256 hashes of MAC addresses 
- Reduce GRUB `recordfail` timeout to 5s
- Global `nginx` webserver
- La La Lab wallpaper

### Changed
- Select default exhibit via host name or user configuration
- Repurpose MiMa script for use in La La Lab
- Use augtool for most modifications of system-wide config files
- Install scripts system wide

### Removed
- BASH scripts for MiMa exhibits

## [0.1.1] - 2018-12-14
### Fixed
- Install script must not copy top level elements
- Trap handler in `repeat-exhibit`

## [0.1.0] - 2018-12-13
### Added
- BASH scripts for launching the minerals menu, the crystal flight menu,
  iOrnament and a the plain kiosk browser
- BASH script to restart programs indefinitely upon exit
- BASH script to hide the cursor while a program is running (using xbanish fork)
- BASH script to stop exhibits and the loop scripts
- BASH script to fake unsupported display resolutions
- Openbox autostart config

[Unreleased]: https://github.com/IMAGINARY/mima-scripts/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/IMAGINARY/mima-scripts/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/IMAGINARY/mima-scripts/compare/v0.0.0...v0.1.0
