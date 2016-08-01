for file in $(find . -mindepth 2 -type f | grep -v  .git); do
	cp $file $HOME
done
unset file
