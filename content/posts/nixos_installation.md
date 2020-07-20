+++
title = "Setting Up NixOS: Dell XPS 9370 4K and EXWM"
author = ["Jacob Chvatal"]
date = 2019-12-20T00:00:00+00:00
lastmod = 2020-07-20T02:42:21+00:00
tags = ["nixos"]
draft = false
+++

I've long been tired of the dependency management of Linux and
wanted to try a new system: [NixOS](https://nixos.org). It's an operating system
centered around system configuration -- a DevOps tool and
a way to manage configuration files as well as a proper
Linux-based operating system.

I did have a bit of trouble installing it so I wanted to
catalogue the process here.

To help with the installation, I referenced [Domen Kozar's instructions](https://gist.github.com/domenkozar/b3c945035af53fa816e0ac460f1df853),
[Jethro's configuration](https://github.com/jethrokuan/nix-config) and [Kyle's configuration](https://github.com/kylesferrazza/nix/). I also made substantial
use of the [NixOS manual](https://nixos.org/nixos/manual) and its instructions. I'll be summarizing steps
taken by each of these articles; refer to the NixOS manual or the instructions
if you'd like more information about the abbreviated steps.

As the title says, I installed `NixOS 20.03` on the Dell XPS 9370 i7 UHD.
I can't guarantee that these instructions will work for your system.
My current configuration, including some of the code mentioned
in this article, can be found [here](https://github.com/jakechv/nix-cfg).

Make sure that you have a flash drive handy with a capacity greater than 2 gigabytes.
My first go used installation media that didn't have the entire ISO written to it
and I had issues booting.


## Setup {#setup}


### Recovery Disk {#recovery-disk}

First remember to create a recovery disk for Windows.
I didn't do this, but it's probably a good idea!
(I'm still looking for my Windows partition...)


### Reboot to the BIOS {#reboot-to-the-bios}

Press F2 repeatedly when the Dell logo appears on boot
(don't hold it, as this may be interpreted as a stuck key)
and reboot into the  BIOS settings.


### BIOS Settings {#bios-settings}

Disable secure boot and RAID mode. It's unclear why RAID mode
is on by default, but this isn't somethign that should be used by the XPS.


### Make an Installation Disk {#make-an-installation-disk}

Download an ISO from [the website](https://nixos.org/download.html). I wouldn't recommend the graphical installation
CD, as it'll take substantially longer to boot and at the time of this writing
offers no real advantage over the minimal installation disk. You'll be using
tools with command-line interfaces anyways.


### Install ISO {#install-iso}

For Linux, I recommend using `dd` to write the media to your USB.
For Windows 10, I'd recommend using [Rufus](https://rufus.ie).

I used Rufus and had trouble with the installation media when writing the ISO,
but using DD mode worked well. I'd recommend using that to start.


## Provisioning the Installation {#provisioning-the-installation}


### Booting the Installation Media {#booting-the-installation-media}

Plug the flash drive into any port on your laptop and reboot.

On boot, press F10 repeatedly to enter the boot selection mode.
Use the up and down arrow keys to navigate to the name of your flash
drive loaded with the installation media. Press enter when the proper
media is highlighted.


### Initial System Configuration {#initial-system-configuration}

The computer should now be booted to the NixOS installer.
It'll show you several images to chose from.

Select `NixOS Live CD` if you're ready to install. The other options
provided may be used if you'd like to try out the operating system
without a full installation.

<!--list-separator-->

-  Troubleshooting

    If the media didn't boot properly and you do not now see a terminal
    showing that you've booted into NixOS, make sure that you've chosen
    the correct installation image for your system. If you provisioned
    your installation media as an ISO, try using DD mode.


### Connecting to The Internet {#connecting-to-the-internet}

Now that you've successfully booted the system, it's time to connect
to the internet. Ethernet would be easy but we still have some networking
tools.

We'll want to do everything as root for the installation, so:

```sh
sudo -i
```

To connect to the internet, run

```sh
wpa_supplicant -i {WiFi card} <(wpa_passphrase "{SSID}" "{password}")
```

where {WiFi card} is the name found with `ifconfig` beginning with
`wlp` or `wlan` (typically `wlan0` or `wlp2s0`),
{SSID} is the name of your WiFi network and {password} is the password
for the network. Make sure that the latter two are both strings.

To confirm your connection, use `ping google.com` or `ping {stable site of choice}`.
If you receive frequent responses at the terminal, you have a connection.


### Partitioning the Drive {#partitioning-the-drive}

I'll yield to the Arch Wiki here; they'll maintain documentation more accurate
and thorough than what I can cover here. Here's the gist of it:

-   Create three partitions:
    -   a boot partition {~100 mb},
    -   a main partition {rest of disk, -1/2 ram size},
    -   and a swap partition {1/2 ram capacity}.
-   Format each with the file system of your choice.
    -   The boot partition should be FAT.
    -   The main partition should be a file system of your choice.
        Use ext4 if you want something simple and reliable;
        use btrfs or zfs if you want something advanced.
    -   The swap partition should be formatted as a swap partition.


### Mounting and Installing {#mounting-and-installing}

This system's a UEFI system, so we'll have to mount two partitions.
Mount your main partition to `/mnt`:
\#begin\_src sh
mount nixos /mnt
\#+end\_src

Mount your boot partition to `/mnt/boot`:
\#begin\_src sh
mkdir -p /mnt/boot
mount boot /mnt/boot
\#+end\_src

This assumes that you've named your main and boot partitions 'nixos' and 'boot' respectively.


## Initial Configuration {#initial-configuration}

Now that everything is mounted, you'll want to generate an initial configuration
for your system.

This can be accomplished with

```sh
nixos-generate-config -d
```


### Editing the Configuration {#editing-the-configuration}

You should now have two files visible in the `/etc/nixos` directory:

-   configuration.nix
-   hardware-configuration.nix

Make sure that hardware-configuration.nix contains three partitions --
one for each partition you created earlier -- with the same file systems
and configurations. If not, update the files with the correct values.


### Initial Configuration {#initial-configuration}

You'll now need to edit properly configure `configuration.nix`.
Most of the defaults are fine, but you'll want to install a sane editor
to make it immediately usable. I'd suggest `vim` or `nvim`.
You'll probably also want `git` and `wget` for saving your configuration or
cloning that of another. Add these to `environment.systemPackages`:

```nix
environment.systemPackages = [
  nvim wget git
];
```

You might also want a better program for configuring networking.
If you're accustomed to Network Manager, add

```nix
~services.networkmanager.enable = true;
```

to the configuration.

You should probably add a user as well.
There's a template for user configuration in the file, but try amending it:

```nix
users.users.{username} = {
  isNormalUser = true;
  home = "/home/{username}";
  extraGroups = [ "wheel" "networkmanager" ];
};
```

You'll want to add yourself to the `"networkmanager"` group
if you're using Network Manager in lieu of wpa\_supplicant.
'Wheel' will allow this user to use `sudo`.


## First Boot {#first-boot}

You're ready to install and boot the system! Run:

```sh
nixos-install
```

Make sure to set the password for the root user to something you remember when prompted.


### Final Touches {#final-touches}

Reboot first: `reboot`.
Now, log in as the root user when prompted for login and password.

Set an initial password for the user you created:

```sh
passwd {username}
```

and provide the password when prompted.

You're now ready to go!
