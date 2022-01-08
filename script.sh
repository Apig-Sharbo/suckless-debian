#!/usr/bin/env bash

#####
## This is to be ran after debian installation is done in "vmware".
## Tested with Debian 11.2 (bullseye)
#####


###
# Before running the script run this to make sure Windows line ending doesn't mess around with this script when downloading from pastebin using curl
# sed -i 's|\r$||' script.sh
###

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install -y curl

pkgver='6.6.0'
fontURL="https://cdn.joypixels.com/arch-linux/font/${pkgver}/joypixels-android.ttf"
fontDir='/usr/share/fonts/joypixels'

sudo mkdir -p "$fontDir" || { printf '%s\n' "Failed to create dir: $fontDir" 1>&2 && exit 1; }
sudo curl -LSso "$fontDir"/joypixels.ttf "$fontURL"
[ -f "$fontDir"/joypixels.ttf ] || { printf '%s\n' 'Failed to install JoyPixels font.' 1>&2 && exit 1; }

sudo apt-get install -y \
  htop \
  xinit \
  git \
  exa \
  curl \
  x11-xserver-utils \
  fonts-noto-mono \
  fonts-noto-color-emoji \
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
libxftVersion=libxft-master
libxftArchive=$libxftVersion.tar.gz
libxftTempFile=/tmp/$libxftVersion.tar.gz
libxftDir=$HOME/$libxftVersion
curl -LSso $libxftTempFile "https://gitlab.freedesktop.org/xorg/lib/libxft/-/archive/master/$libxftArchive"
tar -xzvf $libxftTempFile -C $HOME
[ -d $libxftDir ] || { printf '%s\n' "Could not find dir: $libxftDir" 1>&2 && exit 1; }

curl -LSso $libxftDir/1.patch 'https://gitlab.freedesktop.org/xorg/lib/libxft/merge_requests/1.patch'
patch -d $libxftDir -p1 < $libxftDir/1.patch
sh -c "cd $libxftDir && sh autogen.sh"
make -C $libxftDir
sudo make -C $libxftDir clean install


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
sudo apt-get purge --auto-remove -y nodejs


## Suckless apps:
mkdir -p $HOME/suckless/dwm-apig
git clone 'https://gitlab.com/apig-sharbo/dwm-apig.git' $HOME/suckless/dwm-apig
sudo make -C $HOME/suckless/dwm-apig clean install

mkdir -p $HOME/suckless/st-apig
git clone 'https://gitlab.com/apig-sharbo/st-apig.git' $HOME/suckless/st-apig
sudo make -C $HOME/suckless/st-apig clean install

mkdir -p $HOME/suckless/st-apig
git clone 'https://gitlab.com/apig-sharbo/dmenu-apig.git' $HOME/suckless/dmenu-apig
sudo make -C $HOME/suckless/dmenu-apig clean install


## For startx
cat <<'EOF' > $HOME/.xinitrc
vmware-user &
exec dwm
EOF
