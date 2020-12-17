# About this repo

![BLACK_RPI device preview](https://github.com/baranchuk/blakrpi/blob/readme/_readme_source/blakrpi.preview.2.jpeg?raw=true)

This project is a implementation of [BLACK_RPI](http://www.blakrpi.com/) open source project.

At this moment repo contains 
- Device building documentation 
- Software installation guide 
- Some additional software pack

# Device building documentation

Its placed in `Docs` folder this repo. 

**Diagram.pdf** 

Principle device diagram from device founder ...

**E32-868T20D_Usermanual_EN_v1.7.pdf**

...

**GSM_manual.pdf**

...

**LCSC.xlsx**

...

# Software instalation guide

This block will help you alive your device. It's follow these basic sections: 

- Prepare installation SD card
- Config device installation process
- Kernel compilation
- Keyboard setup
- TFT screen setup
- Oled screen setup
- Audio setup

## Prepare installation SD card

>>> Я бы поработал с этим блоком, складывается ощущение, что по ссылке надо найти сам образ а не софтину, которая этот образ сформирует.

Get latest [Raspian image](https://www.raspberrypi.org/software/).
Write it to SD card (I did use [balenaEtcher](https://www.balena.io/etcher/))

- Create network config file ([wpa_supplicant.conf](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md)) 
- Create empty .ssh file 
>>> Наверное стоит написать хотябы тезисно что это за шаманство с пустым ссш файлом. Все не понятное вызывает недоумение.

Copy these two files to same SD card. 

## First time commands

Plug in SD card to RPI0W at BlakRPI and power it up.

Find BlakRPI IP at your network. 
> &#9432; You can do it via your router interface or use IP scanner. I did use [Angry IP scanner](https://angryip.org/download/). 

>>> А разве там по умолчанию не включен терминал? 
Open terminal, ssh onto your BlakRPI

```bash
ssh pi@[your_BlackRPI_IP]
```

Default credentials
- user: pi
- password: raspberry

> Optionally you can change password using `passwd` command

Run [configuration utility](https://www.raspberrypi.org/documentation/configuration/raspi-config.md)

```bash
sudo raspi-config
```

Navigate to `Interfacing option` menu option
- enable:  "`I2C`",  "`SPI`",  "`serial`", 
- disable: "`serial console`". 

At `Advanced option` menu item select `Resize sd card` option. 

Exit utility and execute command

```bash
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
```

This will update latest software. After finish reboot your BlakRPI

```bash
sudo reboot
```

## Kernel compilation

This section describes **linux kernel** compilation with a TCA8418 keyboard driver support. *This is necessary for the keyboard to work.*

> &#9785; With [kernel building](https://www.raspberrypi.org/documentation/linux/kernel/building.md) and [configuration kernel](https://www.raspberrypi.org/documentation/linux/kernel/configuring.md) manuals i spent a lot of time trying cross-compilation, but got only unstable system with broken dependencies before I got successful result. Compilation on RPI0W with fast (90MB reading/55MB writing speed) took 33-36hrs each retry... so be patient. 

> &#9888; Make sure your ssh connection is stable (my laptop went sleep, breaking ssh and i had to start over).


So after reboot your device
### Install Git and dependencies

>>> в идеале в кратце рассказать что зачем
```bash
sudo apt install git bc bison flex libssl-dev make libncurses5-dev
```

### Clone linus sources (it takes some time)
```bash
git clone --depth=1 https://github.com/raspberrypi/linux
```

### Apply default kernel configuration for `RPI0` by execute next commands
```bash
cd linux
KERNEL=kernel
make bcmrpi_defconfig
```

### Make configuration changes

Start configuration application
>>> не нужно ли перейти внутрь перед запуском? cd /usr/src/linux?
```bash
make menuconfig
```

Navigate to `Device drivers --> Input device support --> Keyboards --> TCA8418 Keypad Support`. 

Press space, `*` is appear. Exit and save your configuration.

IMPORTANT!!! I tried to set name of version at `General setup --> Local version`. NEVER USE SPACE HERE!!!

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

