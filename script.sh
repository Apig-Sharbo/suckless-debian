#!/usr/bin/env bash

#####
##  This is to be ran after debian installation is done in "vmware".
#####


###
# Before running the script run this to make sure Windows line ending doesn't mess around with this script when downloading from pastebin using curl
# sed -i 's|\r$||' script.sh
###

sudo apt-get update -y && sudo apt-get upgrade -y

####
## IMPORTANT
## For whatever reason libxft-bgra will still not work, unless nodejs package is installed.
## Even weirder is that after installing nodejs, removing nodejs again will not stop libxft-bgra from working.
## Installing at the start doesn't fix the issue. The following fixed it:
## sudo apt purge --auto-remove nodejs
## The act of interacting with the package AFTER libxft is installed, seems to make libxft work properly.
## I will install it now, and remove it after libxft installation.
####
sudo apt-get install -y nodejs

pkgver='6.6.0'
FontURL="https://cdn.joypixels.com/arch-linux/font/${pkgver}/joypixels-android.ttf"
FontDir='/usr/share/fonts/joypixels'

sudo mkdir -p "$FontDir" || { printf 'Failed to create dir\n' 1>&2 && exit 1; }
sudo curl -Lo "$FontDir"/joypixels.ttf "$FontURL"

sudo apt-get install -y \
  htop \
  xinit \
  git \
  exa \
  curl \
  x11-xserver-utils \
  fonts-noto-mono \
  fonts-symbola

# For virtualbox-guest-edition
sudo apt-get install -y \
  linux-headers-$( uname -r ) \
  build-essential \
  dkms \
  xclip \
  neovim \
  open-vm-tools-desktop


# For libxft-bgra to compile
sudo apt-get install -y \
  libxrender-dev \
  autoconf \
  xutils-dev \
  libfontconfig-dev \
  libfreetype6-dev \
  libtool-bin \
  libtool

# For suckless apps
sudo apt-get install -y \
  x11proto-dev \
  libx11-dev \
  libxinerama-dev

## Only of you plan to not install libxft-bgra
# sudo apt-get install -y libxft-dev

## Install node from "https://github.com/nodesource/distributions/blob/master/README.md"
  # Using Debian, as root
# sudo bash -c 'curl -fsSL https://deb.nodesource.com/setup_14.x | bash -'
# sudo apt-get install -y nodejs


## libxft-bgra
## Git clone sometimes take way too long to respond.
# git clone https://gitlab.freedesktop.org/xorg/lib/libxft.git
curl -LSsO https://gitlab.freedesktop.org/xorg/lib/libxft/-/archive/master/libxft-master.tar.gz
tar -xzvf libxft-master.tar.gz && rm libxft-master.tar.gz
pushd libxft-master || { printf '%s\n' 'Unable to go to libxft dir' 1>&2 && exit 1; }
curl -LO https://gitlab.freedesktop.org/xorg/lib/libxft/merge_requests/1.patch
patch -p1 < 1.patch
sh autogen.sh
make
sudo make install
popd


## The reason for this is documented above
sudo apt-get purge --auto-remove -y nodejs


## Suckless apps:
mkdir suckless && pushd suckless

git clone https://gitlab.com/apig-sharbo/dwm-apig.git
pushd dwm-apig
sudo make clean install
popd

git clone https://gitlab.com/apig-sharbo/st-apig.git
pushd st-apig
sudo make clean install
popd

git clone https://gitlab.com/apig-sharbo/dmenu-apig.git
pushd dmenu-apig
sudo make clean install
popd

popd


## For startx
cat <<'EOF' > .xinitrc
vmware-user &
exec dwm
EOF
