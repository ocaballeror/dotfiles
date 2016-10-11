thisdir=$(dirname $(readlink -f $(basename $0)))
for file in $(find $thisdir -mindepth 2 -type f | grep -v  .git); do
	cp $file $HOME
done
unset file
. $HOME/.bashrc

if [ $1 = "-r" ] || [ "$1" = "--root" ]; then
	cd /root
	for file in .bashrc .bash_aliases .bash_functions; do
		sudo rm $file
		sudo ln -s $HOME/$file .
	done
fi
