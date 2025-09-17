# monitor-display
This repository stores the scripts necessary to setup and update Raspberry Pi displays for the HMC Makerspace monitors.

## Pi Setup
There are three main parts of monitor setup: flashing the Raspberry Pi, connecting to WiFi, and installing the setup script over SSH.

This guide assumes you have a Raspberry Pi (Zero 2W is used here, but any equivalently powerful machine should work as well), a micro
SD card to store the Pi's operating system, and a laptop to use for SSH control.

To start, flash the micro SD card with the 32-bit Raspbian operating system using the [Raspberry Pi Imager Software](https://www.raspberrypi.com/software/).

When prompted if you would like to apply OS customizations, ensure that the following settings are provided:
- Create a user account (here, assumed to be `makerspace`) and provide a secure password
- Enable SSH
- Set the locale to `United States/Los Angeles` and the keyboard layout to `us`

Finish flashing the media, and upon completion insert it into the Raspberry Pi. Use the included micro USB to USB adapter to plug in a mouse for the next step.
Once the machine boots (it should bypass the login sequence), go to the Wireless LAN icon in the top right corner, enable LAN, and connect to Claremont-ETC.
Disconnect the mouse and plug in a keyboard to enter the password.
Once connected, there should be a popup in the top right that shows the Pi's IP address, which you should note down (something like 172.28.111.111).

On your personal machine, use `ssh makerspace@172.28.111.111` (replacing the Pi's account name and IP address as necessary) to connect to the Pi.
Finally, run the setup script using `curl -sSL https://raw.githubusercontent.com/HMC-Makerspace/monitor-display/refs/heads/main/setup.sh | bash -`.
This should install all necessary dependencies, install a CRON job to restart the slideshow on boot, and reboot the Pi to set the proper configuration.
Finally, in order to update the displays properly, its best to allow your local deivce to access a passwordless SSH connection using a keygen.
If you don't have any SSH keys on your devices, run `ssh-keygen`. Once you have a local key, you can share the public key with the Pi using
`ssh-copy-id makerspace@172.28.111.111`.

## Update Displays
To update all connected Pi displays, start by cloning this git repo on your local device. If you want direct access to the `monitor-display` script,
add `path/to/monitor-display/bin` to your PATH.

To use the script, you will need `imagemagick` and `ghostscript` installed on your device, which can be done using `brew install imagemagick ghostscript`.

Before uploading a slideshow, you must first define the Pi host configuration. If it doesn't already exists, create a `raspi_hosts.txt` file in the
`bin` directory. This file should contain **space-separated hostnames** for all Raspberry Pis you want to be controlled. For example, this might
contain
```txt
makerspace@172.28.111.111 makerspace@172.28.100.100
```

Once this configuration file exists, you can now upload any PDF to the monitors using the `monitor-display` command. Given a PDF file,
the `monitor-display` script will convert the PDF pages into JPGs, zip them into an archive, send the archive to each Pi over `scp`, and then `ssh` into each
machine to restart the `fbi` slideshow process.

## Known Issues/Planned Features
- The script only allows for a single PDF file as input, not multiple PDFs or other filetypes.
- The JPG conversion is currently constant at 72 DPI and 85% quality, but future arguments to the `monitor-display` function should allow for customization.
- In order to synchronize the monitors, we schedule the call to kill and restart the `fbi` process using the Linux `at` command. This is scheduled
for 1 minute after the `monitor-display` is called, rounded down to the nearest minute. If the PDF conversion and transfer operations take longer than this
amount of time, the monitors will not update properly.
