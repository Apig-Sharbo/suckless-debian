#!/usr/bin/env bash

#####
## This is to be ran after debian installation is done in "vmware".
## Tested with Debian 12 (bullseye)
#####

#   -e  Exit immediately if a simple command exits with a non-zero status, unless
#   the command that fails is part of an until or  while loop, part of an
#   if statement, part of a && or || list, or if the command's return status
#   is being inverted using !.  -o errexit
set -e

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install -y \
  automake \
  breeze-icon-theme \
  build-essential \
  cmake \
  curl \
  dkms \
  ffmpegthumbnailer \
  fonts-noto-mono \
  fonts-symbola \
  git \
  htop \
  libfontconfig-dev \
  libfreetype6-dev \
  libtool \
  libtool-bin \
  libx11-dev \
  libxft-dev \
  libxinerama-dev \
  libxrender-dev \
  linux-headers-$( uname -r ) \
  lxappearance \
  mpv \
  open-vm-tools-desktop \
  pcmanfm \
  pulseaudio \
  pulsemixer \
  qbittorrent \
  qt5ct \
  sxiv \
  x11-xserver-utils \
  x11proto-dev \
  xclip \
  xinit \
  xorg \
  xutils-dev

# Docker Stable
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Start pulseaudio
pulseaudio --start
# Unmute audio and set volume to 100
pulsemixer --unmute --set-volume 100


## Only of you plan to not install libxft-bgra
sudo apt-get install -y libxft-dev

# Nix configs
mkdir -p $HOME/.config/nixpkgs
# ALWAYS MAKE SURE TABS ARE USED FOR INDENTATION
cat <<-'EOF' > $HOME/.config/nixpkgs/config.nix
{
  allowUnfree = true;
  joypixels.acceptLicense = true;
}
EOF

## Nix installation for single user
sudo sh <(curl -L https://nixos.org/nix/install) --no-daemon
. /home/debian/.nix-profile/etc/profile.d/nix.sh

nix-env -iA \
        nixpkgs.btop \
        nixpkgs.chromium \
        nixpkgs.fd \
        nixpkgs.joypixels \
        nixpkgs.neovim \
        nixpkgs.ripgrep

## Suckless apps:
Dir=$HOME/suckless/j4-dmenu-desktop
mkdir -p $Dir
git clone 'https://github.com/enkore/j4-dmenu-desktop.git' $Dir
cmake -S $Dir -B $Dir
make -C $Dir
sudo make -C $Dir install

Dir=$HOME/suckless/dwm-apig
mkdir -p $Dir
git clone 'https://gitlab.com/apig-sharbo/dwm-apig.git' $Dir
sudo make -C $Dir clean install

Dir=$HOME/suckless/st-apig
mkdir -p $Dir
git clone 'https://gitlab.com/apig-sharbo/st-apig.git' $Dir
sudo make -C $Dir clean install

Dir=$HOME/suckless/dmenu-apig
mkdir -p $Dir
git clone 'https://gitlab.com/apig-sharbo/dmenu-apig.git' $Dir
sudo make -C $Dir clean install


## For startx
cat <<'EOF' > $HOME/.xinitrc
vmware-user &
exec dbus-run-session dwm
EOF
