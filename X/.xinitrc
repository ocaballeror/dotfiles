xrandr --dpi 160
exec echo "stuff $(date)" >> /home/oscar/success
sh -c /home/oscar/.fehbg &
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

[ -f ~/.Xdefaults ] && xrdb -merge ~/.Xdefaults
