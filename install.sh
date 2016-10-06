thisdir=$(dirname $(realpath $(basename $0)))
for file in $(find $thisdir -mindepth 2 -type f | grep -v  .git); do
	cp $file $HOME
done
unset file
. $HOME/.bashrc
