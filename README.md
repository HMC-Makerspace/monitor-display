# monitor-display v2.0
This repository stores the scripts necessary to setup and update Raspberry Pi displays for the HMC Makerspace monitors.

## Setting up `rclone`
As of v2.0, `monitor-display` now uses `rclone` to sync files between Google Drive and the monitors. In order to setup a new monitor,
you will need to have an `rclone.conf` file in this directory. You can install `rclone` by following
[these instructions](https://rclone.org/downloads/) or simply by running
```bash
brew install rclone
```
on a Mac.

To create an `rclone` configuration file, run
```bash
rclone config --config rclone.conf
```
Configuration should be used as follows:
1. Create a new remote with `n`, and name it `drive`.
2. The storage type should also be `drive`.
3. The client_id and client_secret should be known to the Website/IT Head Steward.
4. Select `2` to use the `drive.readonly` scope.
5. Skip the `service_account` creation, it is not needed
6. Do not edit the advanced config.
7. You will be prompted to login using your Google credentials to authorize the service.
8. Once you have authorized `rclone`, type `y` to use a Shared/Team Drive, and select the appropriate drive.
9. Finally, type `y` to confirm the creation of the `drive` remote, which will be used by the monitors for syncing.

## Pi setup
There are two main parts of monitor setup: flashing the Raspberry Pi and initializing the device with the monitor software.

This guide assumes you have a Raspberry Pi (Zero 2W is used here, but any equivalently powerful machine should work as well), a micro
SD card to store the Pi's operating system, and a laptop to use for SSH control.

To start, flash the micro SD card with the 32-bit Raspbian operating system using the [Raspberry Pi Imager Software](https://www.raspberrypi.com/software/).

When prompted if you would like to apply OS customizations, ensure that the following settings are provided:
- Create a user account with the name `makerspace` and provide a secure password
- Set the locale to `United States/Los Angeles` and the keyboard layout to `us`
- Set `Claremont-ETC` as the default WiFi SSID, and provide the appropriate password
- Enable SSH with password login 

Finish flashing the media, and upon completion insert it into the Raspberry Pi. When the Pi boots, it should automatically connect
to the `Claremont-ETC` network and display its IP address in a popup. Note down this address (something like 172.28.111.111).

> Note: If you do not have any SSH keys installed on your computer, you will need to run `ssh-keygen` before continuing.

On your personal machine, run `./initialize.sh <ip address>` with the appropriate Pi IP address from the previous step.
Enter the password you provided in the Raspberry Pi Imager setup, and watch the magic happen.

This initialization script will install all the necessary dependencies, create a CRON job to sync the Pi's slideshow with a Google Drive folder,
and reboot the Pi to set the proper configuration. At this point, the Pi should reboot and immediately enter the slideshow!

## Uploading new slides
To change the sldies on the monitors, simply upload a new PDF file to the Active Presentation folder located
[here](https://drive.google.com/drive/folders/1xeqqbb0E6t7Ze3OlKfgOyCuykidhcwKU).

## Known Issues
- Currently, all the monitors access a hard-coded drive folder, which must always be accessible in the same location.
- Exactly one PDF must be in the drive folder at any time.
- The maximum number of slides in any deck is 100.
- All monitors use hard-coded `magick` settings for converting the slide PDF into images, which is 144 dpi and 90% quality.
- It is not currently possible to synchronize slides across monitors.
