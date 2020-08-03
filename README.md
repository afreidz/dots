<p align="center"><b>AFreidz AwesomeWM Dotfiles</b></p>
<p align="center"><img width="20%" src="https://github.com/afreidz/dots/raw/master/awesome/user.png"/></p>
<p align="center">
  <a href="#setup">[Setup]</a>
  <a href="#gallery">[Gallery]</a>
</p>

## Details:

<img width="400px" align="right" src="https://i.imgur.com/xpNt1Tp.png"/>

+ **OS** BTW, I use Arch Linux
+ **WM** AwesomeWM v4.3.alkjdsflkadsf [AUR](https://aur.archlinux.org/packages/awesome-git/)
+ **Shell** ZSH with [OH-MY-ZSH](https://aur.archlinux.org/packages/oh-my-zsh-git/)
+ **ZSH Theme** Elessar [Github](https://github.com/fjpalacios/elessar-theme)
+ **Terminal** Rxvt (Unicode) [Pacman](https://www.archlinux.org/packages/?name=rxvt-unicode)
+ **File Manager** Nautilus [AUR](https://aur.archlinux.org/packages/nautilus-git/)
+ **GTK Theme** WhiteSur [GNOME-LOOK](https://www.gnome-look.org/p/1403328/)
+ **Icons** Reversal-Blue [GNOME-LOOK](https://www.gnome-look.org/s/Gnome/p/1340791)
+ **Launcher** Rofi [Pacman](https://wiki.archlinux.org/index.php/Rofi)
+ **Browser** Brave [AUR](https://aur.archlinux.org/packages/brave-bin/)

## Setup
This setup assumes you have installed Arch Linux, `yay`, `git`, and `xorg-server` or otherwise can start an x session. It also assumes that you have ssh keys for the machine added to Github.  That should be it.  If you are on something other than Arch Linux, you will have to manually install all the dependencies and clone this repo to get all the config files.

If you have arch/yay/git/xorg-server up and running you can get the files in this repo into their respective locations with the following:

1. `cd ~/.config`
2. `git init`
3. `git remote add afreidz git@github.com:afreidz/dots.git`
4. `git fetch afreidz`
5. `git pull afreidz master`
6. `rm -rf ~/.config/.git` (to break the link with my github repo and give you freedom to expand)

This config relies heavily on the colors defined in .Xresources.  I know its an outdated pattern, but I prefer as many colors defined variably as possible.  Therefore, you will find my .Xresources file [here](https://github.com/afreidz/dots/tree/master/X).  You can copy/`ln -s` this to the `~/` directory and load it with:

```xrdb ~/.Xresources```

### Install everything else...

I have tried to automate some of the installation process into a bash script.  Running it will prompt you for 4 separate actions:

1. **Required Dependencies** this is awesomewm, picom, and all the CLI packages this config makes use of.
2. **Required Binary Programs** there are a few lightweight programs used in this config to handle some things I have yet to script.  Some of these may not be TRULY required, but YMMV if you choose to skip this
3. **Optional Binary Programs** these are just a few heavier binary programs that I prefer to use daily.  Some/all of them may have awesomewm keybinds, so skipping this could cause a few errors when executing the key combos.
4. **Fonts** there is a system-wide font and an icon font I use in this config.  I had some issues finding working AUR repos for some of them and thus have decided to `curl` a few ttf files.  This will also assume the url to these files still exists.  Don't dog me if they fall off the internetz :)

You can run the setup script with

```bash ~/.config/awesome/scripts/install.sh```

### What next?

With a little luck, this should give you a decent amount of the config I have in the screenshots.  One thing I notice is that there will be no wallpaper by default.  Odds are your screen will be black.  If you run `nitrogen` you can add a folder of images and set your wallpaper.  From there, the config should handle setting it each time you log in.

Keybinds (I use Mod4 or `cmd`/`win` as my modifier):

1. `mod+enter` launch urxvt (careful, if you use a different terminal you will have to update the entry in config.lua or you pretty much wont be able to do anything)
2. `mod+b` launch Brave
3. `mod+f` launch Nautilus File Manager
4. `mod+space` launch rofi to help execute all other apps
5. `mod+shift+q` quit
6. `mod+shift+l` lock
7. `mod+shift+r` reload awesome (it will first prompt you to unlock so you can't bypass the lock screen with a reload)
8. `mod+left/right` move focus to a new client
9. `mod+shift+left/right` swap clients
10. `mod+[/]` resize a small amount
11. `mod+shift+[/]` resize a large amount
12. `mod+0-9` switch to tag
13. `alt+tab` show tag switcher (+ will add a tag to the current mouse screen)
14. `mod+w` close client
15. `mod+Mouse1` move client (make floating)
16. `mod+Mouse3` resize client (make floating)
17. `mod+ctrl+left/right` move client to next screen
18. `mod+ctrl+0-9` move client to tag n
19. `mod+shift+f` toggle client floating
20. `mod+ctrl+f` toggle client fullscreen

Other things:

- right click on an open desktop area to launch the hub (with the display tab)
- click on any icon in the center utilities widget to open the hub with the corresponding tab
- click the date to open the hub (with the calendar tab)
- click the power button to open the power menu
- click the arch button to launch rofi

## Gallery
<p align="center">
  <img width="49%" align="center" src="https://i.imgur.com/hfvdPaL.png"/>
  <img width="49%" align="center" src="https://i.imgur.com/5yxfUGf.png"/>

  <img width="49%" align="center" src="https://i.imgur.com/p8wKEa3.png"/>
  <img width="49%" align="center" src="https://i.imgur.com/FTeo9z8.png"/>

  <img width="49%" align="center" src="https://i.imgur.com/UJ7kp5n.png"/>
  <img width="49%" align="center" src="https://i.imgur.com/tyMQ1DI.png"/>

  <img width="49%" align="center" src="https://i.imgur.com/xlmVZbI.png"/>
  <img width="49%" align="center" src="https://i.imgur.com/9DhRdAE.png"/>

  <img width="49%" align="center" src="https://i.imgur.com/AdFFpkr.png"/>
  <img width="49%" align="center" src="https://i.imgur.com/ERW6GwT.png"/>
</p>
<p align="center">
  <img width="90%" align="center" src="https://i.imgur.com/xpNt1Tp.png"/>
</p>
