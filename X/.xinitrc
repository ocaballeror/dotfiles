#!/bin/sh

customstartup="$HOME/.xcustom"
userresources="$HOME/.Xresources"
usermodmap="$HOME/.Xmodmap"
sysresources="/etc/X11/xinit/.Xresources"
sysmodmap="/etc/X11/xinit/.Xmodmap"

# start some nice programs

if [ -d "/etc/X11/xinit/xinitrc.d" ] ; then
 for f in "/etc/X11/xinit/xinitrc.d/?*.sh" ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

[ -f "$userresources" ] && xrdb "$userresources"
[ -f "$customstartup" ] && source "$customstartup"

# Set the desktop wallpaper
hash feh 2>/dev/null && [ -f "$HOME/.fehbg" ] && sh "$HOME/.fehbg" &

xautolock -detectsleep -time 10 -locker "i3lock-fancy" -notify 30 -notifier "notify-send -u critical -t 100000 -- 'LOCKING SCREEN IN 30 SECONDS'" &

# load up the fonts
xset fp+ $HOME/.fonts/misc
xset fp+ $HOME/.fonts/ohsnap
xset fp+ $HOME/.fonts/terminesspowerline
xset fp+ $HOME/.fonts/tewi
fc-cache -v


# Here i3 is kept as default
session=${1:-i3}

case "$session" in
    awesome           ) exec awesome;;
    bspwm             ) exec bspwm;;
    catwm             ) exec catwm;;
    cinnamon          ) exec cinnamon-session;;
    dwm               ) exec dwm;;
    enlightenment     ) exec enlightenment_start;;
    ede               ) exec startede;;
    fluxbox           ) exec startfluxbox;;
    gnome             ) exec gnome-session;;
    gnome-classic     ) exec gnome-session --session=gnome-classic;;
    i3|i3wm           ) exec i3;;
    icewm             ) exec icewm-session;;
    jwm               ) exec jwm;;
    kde               ) exec startkde;;
    mate              ) exec mate-session;;
    monster|monsterwm ) exec monsterwm;;
    notion            ) exec notion;;
    openbox           ) exec openbox-session;;
    unity             ) exec unity;;
    xfce|xfce4        ) exec startxfce4;;
    xmonad            ) exec xmonad;;
    # Unknown session, try to run it as command
    *) exec $session;;
esac
