xrandr --dpi 160
echo "stuff $(date)" >> /home/oscar/success
sh /home/oscar/.fehbg &
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

[ -f ~/.Xdefaults ] && xrdb -merge ~/.Xdefaults
