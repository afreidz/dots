#! /usr/bin/env bash
FONTS_DIR=/usr/share/fonts/TTF
sudo rm -f $FONTS_DIR/MaterialDesignIconsDesktop.ttf
sudo rm -f $FONTS_DIR/SF-Pro-Rounded-*.ttf
sudo curl -o $FONTS_DIR/MaterialDesignIconsDesktop.ttf https://github.com/Templarian/MaterialDesign-Font/raw/efcf133c42d4b48ab03079541b2b67ca4a0080a9/MaterialDesignIconsDesktop.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Black.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Black.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Light.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Light.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Heavy.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Heavy.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Medium.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Medium.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Thin.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Thin.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Ultralight.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Ultralight.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Regular.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Regular.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Bold.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Bold.ttf
sudo curl -o $FONTS_DIR/SF-Pro-Rounded-Semibold.ttf http://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-SF-Pro-Rounded-Semibold.ttf
yay -S otf-san-francisco --answerclean All --nodiffmenu
sudo fc-cache -r

