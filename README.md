# Mathematikon scripts

These scripts are used on certain interactive stations at the Mathematikon interactive station.

# Installation

## Kiosk OS

The target system for running the script is Ubuntu 18.04.3 provided that the following settings have been applied during installation:

- Choose minimal installation
- Install third-party software for graphics and WiFi hardware... : ON
- Configure secure boot: ON. (set a password; it needs to be entered on first boot)
- When asked for "Installation settings"
   - Choose "Something else"
   - Add 3 partitions:
     - 256 MB EFI system partition
     - 64 MB FAT32 partition named `cfg` and mounted to `/cfg` 
     - Ext4 root partition mounted to `/`
- Account settings:
    + Host name: `mathematikon`
      * When choosing another host name, the [default exhibit needs to be set separately](#autostart).
    + User name: `kiosk`
- Reboot after installation is complete
- Enroll the secure boot keys using the password you entered during secure boot configuration
- Reboot into the system

**Note to myself about `/cfg` partition:** This partition must be FAT32 formatted for `overlayroot` to ignore it. This might break with any future update of `overlayroot` or the kernel resulting in a non-bootable system. This is not optimal but I needed a quick workaround to store changeable configuration data to `/cfg` when the rest of the file system is immutable. **FIXME**

### Bootstrapping

The script `bin/bootstrap-os` will install required packages, the scripts in this repository as
well as most of the exhibits:

```
wget https://raw.githubusercontent.com/IMAGINARY/mathematikon-scripts/master/bin/bootstrap-os
chmod +x bootstrap-os
sudo ./bootstrap-os
```

Some changes made by the bootstrapping script might only take effect after a reboot.

## Immutable file system

The bootstrapping script will ask if it should make the file system immutable after next reboot. This can be very useful to make the whole setup immune to crashes or other modifications of the system. So even if something goes severely wrong during operation, a reboot will usually solve all problems because it resets the system to a well defined state.

The immutable file systems is achieved via `overlayroot` which writes file modifications to a `tmpfs` in RAM instead of the local hard disk. Programs that write a lot of data might cause problems since available RAM might be limited.

Immutability can be toggled using the scripts `enable-overlayroot` and `disable-overlayroot`. Both require a reboot to take effect.

In immutable mode, changes to the local file system can be performed via the `overlayroot-chroot` command but this might have unintented consequences since not all system modifications (such as modifications to the bootloader or `systemd`) work well from within a chroot. So handle with care.

Note that only the root partition is made immutable. It is still possible to write to partitions such as the configuration partition mounted to `/cfg`. 

## Updating

You can either re-run `bootstrap-os` or reinstall/update individual exhibits via the
`install-*` scripts. Note that in most cases, `install-kiosk-scripts` must be executed first
to update the other installation scripts to the most recent version.

## Uninstalling

It is out of the scope of these scripts to provide facilities for uninstalling.
You have to check the installation scripts to figure out how to roll back an installation manually.

Doing so might also be helpful in cases where installations or updates fail. Cleaning previous installations might fix certain issues.

# Starting exhibits
Exhibit start script names are prefixed with `exhibt-` followed by an identifier of that exhibit. See `bin/launch` for a list of known exhibits.

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

By default, a plain X11 session is started that first runs an init script for the exhibit and then runs the exhibit in a loop with mouse cursor hiding enabled.

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

# Default exhibit: content-slider

By default, the [content-slider](https://github.com/IMAGINARY/content-slider) exhibit is [configured](https://github.com/IMAGINARY/content-slider/blob/master/cfg/config.mathematikon-local.yaml) with a selection of [content-slider-apps](https://github.com/IMAGINARY/content-slider-apps).

The exhibit loads a collection of announcements and messages of the day from the partition mounted to `/cfg`:
```
announcements.yaml
anniversary-announcements.yaml
messages-of-the-day.yaml
anniversary-messages.yaml
```
Please consult the documentation of content-slider for the [file format](https://github.com/IMAGINARY/content-slider#messages-of-the-day) and [initial content](https://github.com/IMAGINARY/content-slider/tree/master/cfg/mathematikon).

## Updating messages of the day and announcements

It is possible to update the above files using an external mass storage device such as an USB pen drive:
  - Format a mass storage device with a `FAT32` file system
  - Label the disk `MATHSTATION` (this label should appear in your file explorer)
  - Copy the updated YAML files to the root directory of the `MATHSTATION` device
  - Plug the storage device into the PC
  - The new files will be copied to the `/cfg` partition
  - The exhibit will restart as a sign that the files have been copied successfully
  - Unplug the storage device from the PC

Note that the files will not be verified before copying. File format errors will cause the exhibit to display an error message indicating the file that could not be processed.

### Configuration backups

Each time a configuration is updated, the previous configuration is backed up to `/USB/backups/YYYY-MM-DD_mm-hh-ss`, where `YYYY-MM-DD_mm-hh-ss` is the timestamp of the update.

You can use these backups to go back to a previously working state in case a configuration file contained an error.

## Remote debugging

The exhibit runs in a Chrome-based web browser with remote debugging enabled on port `9222`, which is only exposed on localhost. In order to connect from another host, it is necessary to forward the port, e.g. via `ssh` (executed on said host):
```
ssh -v -N -L 8222:127.0.0.1:9222 kiosk@mathematikon.local
```
This will forward the remote port `9222` to the host's local port `8222`. Note that it might be necessary to exchange `mathematikon.local` for the IP address, depending on your configuration.

Now you can open [chrome://inspect/#devices](chrome://inspect/#devices) in a Chrome-based browser and the exhibit should show up for remote inspection and debugging.

# Additional notes on some of the scripts

## Switching to a regular desktop session

In the plain X11 session, there is not much the user can do besides using the running exhibit (which is intended). Basically, the only way to launch (graphical) applications is via one of the virtual terminals (e.g. <kbd>CTRL</kbd>+<kbd>ALT</kbd>+<kbd>F2</kbd>) or via `ssh`.

It is also possible to leave the plain X11 session and go back to the login screen were you can select another session (e.g. regular Gnome Desktop):
```
stop-kiosk-session
```
Note that the selected session will also be used after reboot if the filessystem isn't immutable. Hence, you should switch back to the plain X11 session once your work in the regular desktop session is done.

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
