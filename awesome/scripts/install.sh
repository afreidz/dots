#! /usr/bin/env bash
REQUIRED_DEPS="yay -S \
w3m \
zsh \
rofi \
xclip \
scrot \
unzip \
bluez \
openssh \
pamixer \
neofetch \
xidlehook \
pulseaudio \
awesome-git \
xorg-server \
imagemagick \
xorg-xrandr \
rxvt-unicode \
oh-my-zsh-git \
networkmanager \
wireless_tools \
pulseaudio-alsa \
picom-ibhagwan-git \
--answerclean All \
--nodiffmenu"

REQUIRED_BINS="yay -S \
lxrandr \
nautilus \
nitrogen \
brave-bin \
pavucontrol \
lxappearance \
nm-connection-editor \
--answerclean All \
--nodiffmenu"

OPTIONAL_BINS="yay -S \
spotify \
font-manager \
slack-desktop \
visual-studio-code-bin \
--answerclean All \
--nodiffmenu"

FETCH_FONTS="$HOME/.config/awesome/scripts/fonts.sh"

read -p "Do you want to install the required dependencies (y/n)?" req_deps_choice
case "$req_deps_choice" in 
  y|Y ) $($REQUIRED_DEPS);;
  n|N ) echo "these are necessary! skipping";;
  * ) echo "invalid! quitting"; exit 1;;
esac
echo ""
read -p "Do you want to install the required binary programs (y/n)?" req_bins_choice
case "$req_bins_choice" in 
  y|Y ) $($REQUIRED_BINS);;
  n|N ) echo "these are necessary! skipping";;
  * ) echo "invalid! quitting"; exit 1;;
esac
echo ""
read -p "Do you want to install optional binary programs (y/n)?" opt_bins_choice
case "$opt_bins_choice" in 
  y|Y ) $($OPTIONAL_BINS);;
  n|N ) echo "skipping optional binary programs";;
  * ) echo "invalid! quitting"; exit 1;;
esac
echo ""
read -p "Do you want to install the fonts (y/n)?" fonts_choice
case "$fonts_choice" in 
  y|Y ) $(sudo bash $FETCH_FONTS);;
  n|N ) echo "skipping fonts";;
  * ) echo "invalid! quitting"; exit 1;;
esac
echo "done"
