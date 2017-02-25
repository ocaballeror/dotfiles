xrandr --dpi 160
sh /home/oscar/.fehbg &
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

echo "Sup $(date) " >> /home/oscar/success
[ -f ~/.Xdefaults ] && xrdb ~/.Xdefaults
exec i3
