#!/usr/bin/env bash

#####
## This is to be ran after debian installation is done in "vmware".
## Tested with Debian 11.2 (bullseye)
#####

#   -e  Exit immediately if a simple command exits with a non-zero status, unless
#   the command that fails is part of an until or  while loop, part of an
#   if statement, part of a && or || list, or if the command's return status
#   is being inverted using !.  -o errexit
set -e

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install -y \
  xorg \
  pulseaudio \
  pulsemixer \
  cmake \
  htop \
  xinit \
  flatpak \
  git \
  curl \
  x11-xserver-utils \
  fonts-noto-mono \
  fonts-noto-color-emoji \
  fonts-symbola \
  linux-headers-$( uname -r ) \
  build-essential \
  dkms \
  xclip \
  neovim \
  open-vm-tools-desktop \
  libxrender-dev \
  automake \
  xutils-dev \
  libfontconfig-dev \
  libfreetype6-dev \
  libtool-bin \
  libtool \
  x11proto-dev \
  libx11-dev \
  libxinerama-dev

# Flatpak setup
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Unmute audio and set volume to 100
pulsemixer --unmute --set-volume 100

## Only of you plan to not install libxft-bgra
# sudo apt-get install -y libxft-dev

## Install node from "https://github.com/nodesource/distributions/blob/master/README.md"
  # Using Debian, as root
# sudo bash -c 'curl -fsSL https://deb.nodesource.com/setup_14.x | bash -'
# sudo apt-get install -y nodejs


## Install JoyPixels font
pkgver='6.6.0'
fontURL="https://cdn.joypixels.com/arch-linux/font/${pkgver}/joypixels-android.ttf"
fontDir='/usr/share/fonts/joypixels'
font="joypixels.ttf"

sudo mkdir -p "$fontDir" || { printf '%s\n' "Failed to create dir: $fontDir" 1>&2 && exit 1; }
sudo curl -LSs -o "$fontDir/$font" "$fontURL"
[[ -f $fontDir/$font ]] || { printf '%s\n' 'Could not find JoyPixels font.' 1>&2 && exit 1; }


## libxft-bgra
## Git clone sometimes take way too long to respond.
# git clone https://gitlab.freedesktop.org/xorg/lib/libxft.git
libxftVersion=libxft-master
libxftArchive=$libxftVersion.tar.gz
libxftTempFile=/tmp/$libxftArchive
libxftDir=/opt/$libxftVersion
libxftRepo="https://gitlab.freedesktop.org/xorg/lib/libxft/-/archive/master/$libxftArchive"
libxftPatch='1.patch'
libxftPatchURL="https://gitlab.freedesktop.org/xorg/lib/libxft/merge_requests/$libxftPatch"

if [[ ! -d /opt ]]; then
    sudo mkdir /opt || { printf '%s\n' 'Failed to create dir: /opt' 1>&2 && exit 1; }
fi

sudo curl -LSs -o $libxftTempFile $libxftRepo
[[ -f $libxftTempFile ]] || { printf '%s\n' "Could not find file: $libxftTempFile" 1>&2 && exit 1; }

sudo tar -xzvf $libxftTempFile -C ${libxftDir%/*}
[[ -d $libxftDir ]] || { printf '%s\n' "Could not find dir: $libxftDir" 1>&2 && exit 1; }

sudo curl -LSs -o $libxftDir/$libxftPatch $libxftPatchURL
[[ -f $libxftDir/$libxftPatch ]] || { printf '%s\n' "Could not find file: $libxftDir/$libxftPatch" 1>&2 && exit 1; }

sudo patch -d $libxftDir -p1 < $libxftDir/$libxftPatch
sudo sh -c "cd $libxftDir && sh autogen.sh"
sudo make -C $libxftDir
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
# sudo apt-get purge --auto-remove -y nodejs


## Suckless apps:
mkdir -p $HOME/suckless/j4-dmenu-desktop
Dir=$HOME/suckless/j4-dmenu-desktop
git clone 'https://github.com/enkore/j4-dmenu-desktop.git' $Dir
cmake -S $Dir -B $Dir
make -C $Dir
sudo make -C $Dir install

mkdir -p $HOME/suckless/dwm-apig
Dir=$HOME/suckless/dwm-apig
git clone 'https://gitlab.com/apig-sharbo/dwm-apig.git' $Dir
sudo make -C $Dir clean install

mkdir -p $HOME/suckless/st-apig
Dir=$HOME/suckless/st-apig
git clone 'https://gitlab.com/apig-sharbo/st-apig.git' $Dir
sudo make -C $Dir clean install

mkdir -p $HOME/suckless/st-apig
Dir=$HOME/suckless/dmenu-apig
git clone 'https://gitlab.com/apig-sharbo/dmenu-apig.git' $Dir
sudo make -C $Dir clean install


## For startx
cat <<'EOF' > $HOME/.xinitrc
vmware-user &
exec dbus-run-session dwm
EOF
