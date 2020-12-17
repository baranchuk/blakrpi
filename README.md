# About this repo

![BLACK_RPI device preview](https://github.com/baranchuk/blakrpi/_readme_source/blakrpi.preview.jpeg)

This project is a implementation of [BLACK_RPI](http://www.blakrpi.com/) open source project.


## Sd card preparation

Get latest [Raspian image](https://www.raspberrypi.org/software/).
Write it to sd card (I use [balenaEtcher](https://www.balena.io/etcher/))

Prepare your [wpa_supplicant.conf](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) and clear .ssh file and copy it to your sd card. Now time to insert your sd card to your RPI0W at BlakRPI and power it up first time!

## First time commands

Find IP of your BlakRPI at your network. You can do it via your router interface or use IP scanner. I use [Angry IP scanner](https://angryip.org/download/). 

Open terminal, ssh onto your BlakRPI

`ssh pi@[your_BlackRPI_IP]`

default credentials
user:pi
password:raspberry

Now you can change password using `passwd` command

Run [configuration utility](https://www.raspberrypi.org/documentation/configuration/raspi-config.md)

`sudo raspi-config`

At menu select `Interfacing option` and enable I2C, SPI, serial, but disable serial console. 
At Advanced option menu select `Resize sd card` option. 
Exit utility and do command

`sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y`

to get latest software. After it finished reboot your BlakRPI 

`sudo reboot`

## Kernel compilation

At this section we recompile linux kernel to get TCA8418 keyboard driver kernel support. It need to get keyboard work. I use [kernel building](https://www.raspberrypi.org/documentation/linux/kernel/building.md) and [configuration kernel](https://www.raspberrypi.org/documentation/linux/kernel/configuring.md) manuals. I spend many time trying cross-compilation, but get unstable system with broken dependencies. Compilation on RPI0W with fast (90MB reading/55MB writing speed) take 33-36hrs, please be patient. Make shure your ssh connection is stable (my notebook go sleep, broke ssh and i need to start over).

Installing Git and build dependencies

`sudo apt install git bc bison flex libssl-dev make libncurses5-dev`

get sources (it take some time)

`git clone --depth=1 https://github.com/raspberrypi/linux`

apply default kernel configuration for RPI0

`cd linux`

`KERNEL=kernel`

`make bcmrpi_defconfig`

make configuration changes

`make menuconfig`

Go to `Device drivers --> Input device support --> Keyboards --> TCA8418 Keypad Support`. Press space, `*` is appear. Exit and save your configuration. IMPORTANT!!! I try to get name of version at General setup --> Local version. NEVER USE SPACE HERE!!!

building (take 33-35hrs at fast sd card, be patient!)

`make zImage modules dtbs`

install new kernel and modules

`sudo make modules_install`

`sudo cp arch/arm/boot/dts/*.dtb /boot/`

`sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/`

`sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/`

`sudo cp arch/arm/boot/zImage /boot/$KERNEL.img`

Another option is to copy the kernel into the same place, but with a different filename - for instance, kernel-myconfig.img - rather than overwriting the kernel.img file. You can then edit the `/boot/config.txt` file to select the kernel that the Pi will boot into:`kernel=kernel-myconfig.img`

New kernel installed, time to reboot

`sudo reboot`

## Keyboard setup

Now you can follow [manual](http://www.blakrpi.com/index.php/2020/08/04/keyboard-mapping/) to get your keyboard work. Just one thing more - you need to add `dtoverlay=tca8418` string at your `/boot/config.txt` after overlays compiling, before reboot and test your keys.


## TFT Screen setup

Install dependencies

`sudo apt-get install cmake git`

get and compile driver

`git clone https://github.com/juj/fbcp-ili9341.git`

`cd fbcp-ili9341`

`mkdir build`

`cd build`

`cmake -DILI9341=ON -DGPIO_TFT_DATA_CONTROL=24 -DGPIO_TFT_RESET_PIN=25 -DSPI_BUS_CLOCK_DIVISOR=6 -DDISPLAY_ROTATE_180_DEGREES=ON -DSTATISTICS=number0  ..`

`make -j`

test driver

`sudo ./fbcp-ili9341`

Now your tft screen appear console. If not - find your hardware issue. To start it on boot edit your `/etc/rc.local` file and insert before exit 0 at end of file `sudo /home/pi/fbcp-ili9341/build/fbcp-ili9341 &` and save it.

add to your `/boot/config.txt` to fix screen resolution and size

`hdmi_group=2`
`hdmi_mode=87`
`hdmi_cvt=320 240 60 1 0 0 0`
`hdmi_force_hotplug=1`


After rebooting log messages appear on boot and you can log on to your BlakRPI at it screen and keyboard. 
I dont like RPI logo and non-critical boot messages, so if your want to get clear boot edit your `/boot/cmdline.txt`
Replace `console=tty1` by `console=tty3` to redirect boot messages to the third console,
add `loglevel=3` to disable non-critical kernel log messages,
add `logo.nologo` to disable RPI logo.


## Oled setup

At this section I use [Adafruit PiOLED manual](https://learn.adafruit.com/adafruit-pioled-128x32-mini-oled-for-raspberry-pi/usage).

Install dependencies

`sudo apt-get install python3-pip python3-pil`

`sudo pip3 install adafruit-circuitpython-ssd1306`

edit your `~pi/stats.py`
insert [code](https://learn.adafruit.com/pages/15678/elements/3024322/download) save and exit. 

Try to get it work `sudo python3 ~/stats.py`. Now your OLED screen will appear IP adress, cpu, memory and storage usage. If not - maybe hardware issue

To start it on boot edit your `/etc/rc.local` file and insert before exit 0 at end of file `sudo python3 /home/pi/stats.py &` and save it.

## Audio setup

At this section I use [Waveshare driver](https://github.com/waveshare/WM8960-Audio-HAT). Now audio output works well, but recording have an issue. Need time to get it work. In progress now

