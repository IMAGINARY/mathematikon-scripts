# La La Lab scripts

These scripts are used on certain interactive stations at the exhibition “La La Lab – the Mathematics of Music”.

# Installation

## La La Lab OS

The target system for running the script is Ubuntu 18.04.2 provided that the following settings have been applied during installation:

- Choose minimal installation
- Install third-party software for graphics and WiFi hardware... : ON
- Configure secure boot: ON. (set a password; it needs to be entered on first boot)
- Account settings:
    + User name: `lalalab`
- Reboot after installation is complete
- Enroll the secure boot keys using the password you entered during secure boot configuration
- Reboot into the system

### Bootstrapping

The script `bin/bootstrap-lalalabos` will install required packages, the scripts in this repository as
well as most of the exhibits:

```
wget https://raw.githubusercontent.com/IMAGINARY/lalalab-scripts/master/bin/bootstrap-lalalabos
chmod +x bootstrap-lalalabos
sudo ./bootstrap-lalalabos
```

Some changes made by the bootstrapping script might only take effect after a reboot.

## Immutable file system

The bootstrapping script will ask if it should make the file system immutable after next reboot. This can be very useful to make the whole setup immune to crashes or other modifcations of the system. So even if something goes severely wrong during operation, a reboot will usually solve all problems because it resets the system to a well defined state.

The immutable file systems is achieved via `overlayroot` which writes file modifications to a `tmpfs` in RAM instead of the local hard disk. Programs that write a lot of data might cause problems since available RAM might be limited.

Immutability can be toggled using the scripts `enable-overlayroot` and `disable-overlayroot`. Both require a reboot to take effect.

In immutable mode, changes to the local file system can be performed via the `overlayroot-chroot` command but this might have unintented consequences since not all system modifications (such as modifications to the bootloader or `systemd`) work well from within a chroot. So handle with care.

## Updating

You can either re-run `bootstrap-lalalabos` or reinstall/update individual exhibits via the
`install-*` scripts. Note that in most cases, `install-lalalab-scripts` must be executed first
to update the other installation scripts to the most recent version.

## Uninstalling

It is out of the scope of these scripts to provide facilities for uninstalling.
You have to check the installation scripts to figure out how to roll back an installation manually.

Doing so might also be helpful in cases where installations or updates fail. Cleaning previous installations might fix certain issues.

# Starting exhibits
Exhibit start script names are prefixed with `exhibt-` followed by an identifier of that exhibit. See `bin` for a list of known exhibits.

# Restart exhibits after a crash
The script `repeat-exhibit` will restart the executable supplied as argument indefinitely, e.g.
```
repeat-exhibit exhibit-kiosk
```
will restart `exhibit-kiosk` if it exits for whatever reason.

# Stopping exhibits
All exhibits can be stopped via
```
stop-exhibits
```
This includes the `repeat-exhibit` script and any process whose name starts with `exhibit-`.

# Autostart

By default, an openbox session is started that first runs an init script for the exhibit and then runs the exhibit in a loop with mouse cursor hiding enabled.

The init script is supposed to run only once and it needs to exit once the init tasks are performed. Otherwise, script execution will block and no exhibit will be started.

By default, init scripts and exhibits are selected via the host name of the system (see `bin/get-default-exhibit-by-hostname`).
It is possible to override this behavior to allow for user-defined exhibits. If the following executables are present, they will be run instead of the system-wide default:
```
~/.exhibition/default-init
~/.exhibition/default-exhibit
```
Note that these executables can be scripts themselves or just symlinks to one of the `init-*` respectively `exhibit-*` scripts. If no special initialization is needed, you can just create a symlink to `true`:
```
ln -s `which true` ~/.exhibition/init-default
```

# Additional notes on some of the scripts

## Hide the cursor
The script `hidecursor` hides the cursor and starts another child process supplied as an argument.
When the child exits, the cursor will not be hidden anymore.

## Fake display resolution for testing
Sometimes the display used for development does not match the resolution used in production.
Assume your test display has a default resolution of `1920x1080` (FullHD), but in production, `3840x2160` (UHD) is used.
The command
```
fakeResolution 3840x2160
```
will allocate a `3840x2160` frame buffer and will scale it down to `1920x1080`.

If aspect ratios do not match, the image will be stretched.
