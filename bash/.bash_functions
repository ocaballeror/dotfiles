#!/bin/bash
# Theoretically, this should be the return codes:
#	0 - Everything went as planned
#	1 - There was an error in the arguments (unsufficient, mistyped...)
#	2 -	Referenced files or directories do not exist
#	3 - Other
#
#	THIS IS STILL NOT CONSISTENT, THOUGH. RETURN CODES SHOULDN'T BE TRUSTED YET
#
#	THIS IS A BIG TO-DO. DON'T BE SO LAZY AND ACTUALLY DO SOME WORK YOU LAZY ASS PRICK

cd_func (){
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  ls
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

# Give some use to the above function
alias cd=cd_func

cdvm() {
	local usage="Usage: ${FUNCNAME[0]} <VMName>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	local vmpath="/media/$USER/Data/Software/VirtualBoxVMs"
	[ ! -d $vmpath ] && vmpath=$(find /media/$USER/Data/Software -type d -name "VirtualBoxVMs")
	[ ! -d $vmpath ] && vmpath=$(find /media/$USER/Data/ -type d -name "VirtualBoxVMs")	
	[ ! -d $vmpath ] && { echo "Err: Could not find VMs folder"; return 3; }

	local vmname=$vmpath/$1
	if [ ! -d $vmname ]; then
		local ivmname="$(find $vmpath -maxdepth 1 -type d -iname $1 | head -1)"
		if [ -n "${ivmname// }" ]; then # Eliminate white spaces
			local opt
			echo -n "Did you mean \"$(basename $ivmname)\"? (y/n): "
			read opt
			[ $opt = 'y' ] && vname="$ivmname"\
			|| { >&2 echo "Err: $1 is not a VM"; return 2; }
		else
			>&2 echo "Err: $1 is not a VM"
			return 2
		fi
	fi

	cd $vmname
}

code(){
	local force=false
	[ $1 == "-f" ] && { force=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <Program> [destination]"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	if ! $force && hash yaourt 2> /dev/null; then
		if [ "$(yaourt -Ssq $1 | grep -E "^$1$")" ]; then
			[ $target ] && cd $target
			yaourt -G $1
			cd $1
		else
			echo "Program '$1' not found in repos"
			return 2
		fi
	else # I guess we'll have to do it the pacman way. That is, with sudo commands
		local repo=$(pacman -Ss $1  | grep -E ".*/$1 .*[0-9]+[\.[0-9]*|\-[0-9]]+" | cut -d / -f1)
		if [ $repo ]; then
			sudo abs
			sudo abs $1
			local target="$HOME/Stuff"
			if [ -n "$2" ]; then
				if [ ! -d "$2" ]; then
					echo "W: Directory $2 not found. Will copy to ~/Stuff"
				else
					target=$2
				fi
			fi

			cp -r "/var/abs/$repo/$1" $target
			cd $target/$1
		fi
	fi
	makepkg -od
	cd src/
	[ $(ls -d */) ] && cd $(ls -d */)
	# if [ $? = 1 ]; then
	# 	local ball=$(ls *.tar* 2>/dev/null | head -1)
	# 	if [ -z $ball ]; then
	# 		ball=$(ls *.zip 2>/dev/null | head -1)
	# 		if [ -z $ball ]; then
	# 			echo "Error making package. Probably something to do with PGP keys"
	# 			return 3
	# 		fi
	# 	fi
	# 	tar -zxf $ball
	# fi
}

comp(){
	_comp_junk $* 2>/dev/null
}

_comp_junk() {
	# TODO Argument parsing
	#Dat parsing, though
	[ $1 = "-m" ] && {
		local dif=$2
		hash $dif 2>/dev/null && shift 2 \
			|| { echo "Program '$2' is not installed"; return 2; }
	}

	local usage="Usage: ${FUNCNAME[0]} <list-of-files>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }
	for name in $*; do [ ! -f $name ] && { echo "File '$name' does not exist"; return 2; }; done

	for dif in meld colordiff diff; do
		hash $dif 2>/dev/null && break
	done
	[ $dif != "meld" ] && echo "The installation and use of meld is recommended"

	local changed=false
	while [ $# -ge 2 ]; do
		if [ $(($# % 2)) = 0 ]; then
			$(cmp -s "$1" "$2") || { changed=true; $dif "$1" "$2"; }
			shift 2
		elif [ $# = 3 ]; then 
			# Results in this order: all equal, 3 is different, 1 is different, 2 is different, all are different
			$(cmp -s "$1" "$2")\
				&&  ($(cmp -s "$1" "$3") && continue || $dif "$1" "$3")\
				||  ($(cmp -s "$2" "$3") && $dif "$1" "$2" ||\
					($(cmp -s "$1" "$3") && $dif "$1" "$2" || $dif "$1" "$2" "$3"))
			changed=true
			shift 3
		fi
	done

	$changed || echo "Nothing to see here"
	[ $# = 1 ] && { echo "Couldn't handle last argument '$1'"; return 4; }
	return 0
}

cpc() {
	if [ $# -ge 2 ]; then
		for dst; do true; done
		if ! [ -d $dst ]; then
			echo "Err: Destination directory not found"
			return 1
		fi

		# We'll concat the string so it's only one command (is it more efficient?)
		local cmmd="cp -vr"
		while [ $# -gt 1 ]; do
			cmmd="$cmmd $1"
			shift
		done
		cmmd="$cmmd $dst"
		$cmmd #Actually execute the command
		cd "$dst"
	else
		echo "Err: Missing arguments"
		return 1
	fi

	return 0
}

# Takes any number of switches for cp
# TODO Properly eliminate multi-switch duplicates
cpvm() {
	# TODO Argument parsing
	# Quite a hacky way to do things, but it does the job
	local switches="rv" # The only default switch
	while [[ $1 =~ -.* ]]; do
		local newswitch=${1##*-}
		[ ! $(echo $switches | grep $newswitch) ] && { switches+=$newswitch; } # Eliminate duplicates
		shift
	done

	# And now that we have our cp switches, parse the arguments as normal
	local usage="Usage: ${FUNCNAME[0]} [copyopts] <files> <VMName>
    OR ${FUNCNAME[0]} [copyopts] <VMName> <files>"

	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	for last; do true; done

	local vmpath=$(find /media/$USER/Data/ -type d -name "VirtualBoxVMs")
	[ -z $vmpath ] && { >&2 echo "Err: Could not find VMs folder"; return 3; }
	local flipped=false
	local target="$vmpath/$last/Shared"
	if ! [ -d $target ]; then # Try to flip the arguments
		if [ -d ${target%Shared} ]; then # Does the vm even exist?
			echo "W: Had to create the folder called Shared. The folder sharing mechanism may not be set up"
			mkdir $target
		else
			target="$vmpath/$1/Shared" #Let's see if the vm name came first
			if ! [ -d $target ]; then
				if [ -d ${target%Shared} ]; then
					echo "W: Had to create the folder called Shared. The folder sharing mechanism may not be set up"
					mkdir $target
				else #Neither the first nor the last arguments are VMs
					if 	[ -e "$1" ]; then
						>&2 echo "Err: $last is not a VM"
					elif [ -e "$last" ]; then
						>&2 echo "Err: $1 is not a VM"
					else
						>&2 echo "Err: Bad arguments"
						return 2
					fi
					return 2
				fi
			fi
			flipped=true
		fi
	fi
	
	#We should have at least the -r switch right now.
	cmmd="cp -$switches " #Notice the blank space at the end
	if ! $flipped; then 
		while [ $# -gt 1 ]; do
			[ ! -e "$1" ] && [ "$1" != "$last" ] && { >&2 echo "Err: Source file '$src' does not exist"; return 2; }
			cmmd+="$1 "
			shift
		done
	else
		while [ $# -ge 2 ]; do
			[[ ! -e "$2" ]] && { >&2 echo "Err: Source file '$src' does not exist"; return 2; }
			cmmd+="$2 "
			shift
		done
	fi

	eval $cmmd $target

	return 0
}

cunzip(){
	local usage="Usage: ${FUNCNAME[0]} <zipfile> <destination>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	[ ! -f $1 ] || [ ${1##*.} != "zip" ] && { echo "Not a valid zip file"; return 2; }
 
	[ ! -d $2 ] && mkdir $2
	unzip $1 -d $2
	cd $2

}

diffsum() { 
	local usage="Usage: ${FUNCNAME[0]} <algorithm> <file> <original sum>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	local algor
	if ! hash $1 2> /dev/null; then
		if [ $(echo $1 | grep -v sum) ]; then
			local new1="$1sum"
			if ! hash $new1 2> /dev/null; then
				echo "'$1' does not exist or is not installed"
				return 1
			else
				algor=$new1
			fi
		else
			echo "'$1' does not exist or is not installed"
			return 1
		fi
	else
		algor=$1
	fi

	[ ! -f $2 ] && { echo "File '$2' does not exist or is not regular"; return 2; }

	local orig
	if ! [ $3 ]; then #We will assume there's a sum file
		local alg=${algor%sum}
		local filename
		for filename in "${2%.*}.$alg" "${2%.*}.sum" "$2sum" "$algor" "sums" "sum"; do #Try all the options
			if [ -f "$filename" ]; then
				orig=$(grep $2 $filename)
				break #We got our file and are done trying. Let's get that sum
			fi
		done
		if ! [ "$orig" ]; then
			echo "Err: could not find a sum file and no arg was provided"
			return 3
		fi
	else
		orig="$3  $2" #Sums usually have this format
	fi

	echo $orig

	local sum=$($algor $2)

	if [ "$sum" = "$orig" ]; then
		echo "OK"
	else
		echo "Verification failed. The actual sum is:  $sum
		vs $orig"
		return 3
	fi

	return 0
}


drive() {
	local MP=$(ps aux | grep gdfs | grep -v grep)
    if [ "$MP" ]; then
    	MP=${MP##* } # Get the last word of the process, which should be the mountpoint
    	sudo fusermount -uz $MP
    	sudo pkill -9 gdfs
    else
    	MP="/media/oscar/gdfs"
    fi
    
    [[ "$1" = "-k" ]] && return 0

   	[[ ! -d "$MP" ]] && mkdir -p "$MP"
    sudo gdfs -o big_writes -o allow_other /home/oscar/.config/gdfs/gdfs.auth "$MP"

    if [ -d /home/oscar/Drive ] && [[ $1 != "-n" ]]; then
        find /home/oscar/Drive > /dev/null &
    fi
    return 0
}


dump() {
	#TODO Argument parsing
	#Wow, that's messed up
	[ "$1" = "-a" ] && { aggressive=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <dir>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }
	[ ! -d $1 ] && { echo "Directory '$1' not found"; return 2; }

	local moved=false
	[ $1 != '.' ] && { cd $1; local moved=true; }
	for afile in **/*; do
		if $aggressive; then
			mv $file .
		else
			[ -f $afile ] && {
				local dest="$(dirname $(dirname "$afile"))"
				[ "$(realpath $dest)" = "$(realpath ..)" ] && dest=. # Keep everything in the folder we're dumping.
				#echo "$afile" to "$dest"
				mv -v "$afile" "$dest" 2> /dev/null
			}
		fi
	done

	$moved && { cd -; }

	return 0
}

folder() {
	local usage="Usage: ${FUNCNAME[0]} <device>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	local folder="folder"
	#Best argument parsing ever
	if [ $1 = "-k" ] || [ $1 = "kill" ]; then
		folder=$(realpath "$folder")
		if [ ! -d "$folder" ] || [ -z "$(df "$folder")" ]; then

			#If we're in a mounted system, which has been mounted on a folder called ""$folder""
			#(avoid jumping up to and unmountig a folder that we didn't mount)
			local mp="$(df --output=target . | tail -1)"
			if [[ "$mp" =~ .*"$folder".* ]] || [[ "$folder" =~ .*"$mp".* ]]  ; then 
				 cd "$(dirname "$mp")" #Jump up to our mountpoint
				 folder="$mp" #Change the folder we will umount down below
			else
				echo "Err: No parent mountpoint or it's not one of our own."
				mp="$(df --output=target | grep -E "$folder$" | tail -1)"
				if [ $mp ]; then
					local opt
					if [[ "$2" != '-f' ]]; then
						local src=$(df --output=source $mp | tail -1)
						local fstype=$(df --output=fstype $mp | tail -1)
						echo -n "Do you want to risk it and unmount $src [$fstype] from $mp? (y/N): "
						read opt
					else
						opt='y'
					fi
					[[ $opt = 'y' ]] && sudo umount $mp || echo "Aborted."
					return 0
				else
					return 3
				fi
			fi
		fi
		sudo umount "$folder" && rmdir "$folder" #Use rmdir just in case something went wrong and the folder is not empty
		return
	fi

	local device
	local sdXY="^sd[a-z][0-9]*$"
	local dXY="^[a-z][0-9]*$"

	if [[ $1 =~ $sdXY ]]; then
		device="/dev/$1"
	elif [[ $1 =~ $dXY ]]; then
		device="/dev/sd$1"
	else
		device=$1
	fi

	#echo $device

	if ! [ -b $device ]; then
		echo "Err: Device '$device' does not exist"
		return 2
	else
		if grep -qs $device /proc/mounts; then
			sudo umount $device
		fi

		if ! [ -d "$folder" ]; then			
			mkdir "$folder"
		fi
		sudo mount $device "$folder" || { ret=$?; rmdir "$folder"; return $ret; }
		sudo -n chown $USER:$USER "$folder" 2>/dev/null #Could fail on write-protected filesystems
	fi
#	cd "$folder"

	return 0
}

iso() {
	#TODO Argument parsing
	if [ $# -lt 1 ]; then
		echo "No arguments provided"
		return 1
	fi

	FILE=$1
	filename="${FILE%%.*}"
	extension="${FILE##*.}"
	out=$filename.iso

	if [ $# -gt 1 ]; then
		out=$2
	fi

	case $extension in 
		"mdf")
			if ! hash mdf2iso 2> /dev/null; then
				echo "Can't continue. mdf2iso is not installed"
				return 3
			else
				mdf2iso $FILE $out
			fi;;
		"ccd"|"img")
			if ! hash ccd2iso 2> /dev/null; then
				echo "Can't continue. ccd2iso is not installed"
				return 3
			else
				ccd2iso $FILE $out
			fi;;
		"nrg")
			if ! hash nrg2iso 2> /dev/null; then
				echo "Can't continue. nrg2iso is not installed"
				return 3
			else
				nrg2iso $FILE $out
			fi;;
		"bin")
			if [ $# -lt 2 ]; then
				echo "2 files are needed for bin+cue conversion"
				return 1
			fi
			if ! hash bchunk 2> /dev/null; then
				echo "Can't continue. bchunk is not installed"
				return 3
			fi

			FILE2=$2
			filename2="${FILE2%%.*}"
			extension2="${FILE2##*.}"

			if [ $extension2 != "cue" ]; then
				echo "Wrong format" $extension2
				return 2
			fi

			if [ $# -gt 2 ]; then
				out=$3
			else
				out=$filename.iso
			fi

			bchunk $FILE $FILE2 $out;;

		"cue")
			if [ $# -lt 2 ]; then
				echo "2 files are needed for bin+cue conversion"
				return 1
			fi

			if ! hash bchunk 2> /dev/null; then
				echo "Can't continue. bchunk is not installed"
				return 3
			fi

			FILE2=$2
			filename2="${FILE2%%.*}"
			extension2="${FILE2##*.}"

			if [ $extension2 != "bin" ]; then
				echo "Wrong format" $extension2
				return 1
			fi

			if [ $# -gt 2 ]; then
				out=$3
			else
				out=$filename2.iso
			fi

			bchunk $FILE2 $FILE $out;;
		*)
			echo "I don't know what the fuck to do with" $1
			return 2;;
	esac
	return 0
}

lines(){
	local OPTIND files cwd depth extensions	# Need to declare it local inside functions
	while getopts ":d:m:h" opt; do
		case $opt in
			d)
				if [ -d $OPTARG ]; then
					files=$OPTARG
					if [ "${OPTARG:$((${#OPTARG}-1)):1}" != "/" ]; then ##Get the last char of the string
						files=$files/
					fi
					cwd=$files
				else
					echo "Err: Directory $OPTARG does not exist"
					return 2
				fi;;
			m)
				depth=$OPTARG
				if [ $depth -lt 1 ]; then 
					echo "You won't get any results with such a stupid depth"
					return 2
				fi;;
			\?)
				>&2 echo "Err: Invalid option -$OPTARG"
				echo usage
				return 1;;
			:)
				>&2 echo "Err: Option -$OPTARG requires an argument"
				return 1;;
		esac
	done

	shift $(($OPTIND -1))
	if [ $# -gt 0 ]; then
		extensions=( "$@" )
	else
		extensions=( c cpp h hpp S asm java js clp hs py pl sh cs css cc html htm sql rb )
	fi

	if [ -z $depth ]; then
		depth=$(($(find . | tr -cd "/\n" | sort | tail -1 | wc -c) -1))
	fi
	for ext in ${extensions[@]}; do
		for aux in $(seq $depth); do
			for i in $(seq $((aux-1))); do
				files+='*/'
			done
			files+="*.$ext $cwd"
		done
	done

	wc -l $files 2>/dev/null | sort -hsr | more
}

#Copied from http://unix.stackexchange.com/a/155633
#Doesn't work as a function for some reason, but it does when it's run as a 
#separate script on a local folder. TODO look into this bs
merge(){
	DEST="${@:${#@}}"
	ABS_DEST="$(cd "$(dirname "$DEST")"; pwd)/$(basename "$DEST")"

	for SRC in ${@:1:$((${#@} -1))}; do   (
	    cd "$SRC";
	    find . -type d -exec mkdir -p "${ABS_DEST}"/\{} \;
	    find . -type f -exec mv \{} "${ABS_DEST}"/\{} \;
        find . -type d -empty -delete
	) done
	
	rmdir $1
}

mp3(){
	local usage="Usage: ${FUNCNAME[0]} <url>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	youtube-dl $1 -x --audio-format mp3 --audio-quality 0
}

#Move and cd
mvc() {
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <destination>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	for dst; do true; done
	if ! [ -d $dst ]; then
		echo "Err: Destination directory not found"
		return 2
	fi

	# We'll concat the string so it's only one command (is it more efficient?)
	local cmmd="mv -v"
	while [ $# -gt 1 ]; do
		cmmd=$(echo "$cmmd $1")
		shift
	done
	cmmd=$(echo "$cmmd $dst")
	$cmmd #Actually execute the command
	cd "$dst"

	return 0
}

_oldvpnkill() {
	[ "$(ps aux | grep openvpn | grep -v grep)" ] && sudo pkill -9 openvpn
}

oldvpn() {
	local path="/etc/openvpn"
	local region="Germany"
	trap "_vpnkill; return" SIGINT SIGTERM
	if [ $# -gt 0 ]; then
		if [ -f "$path/$1.conf" ]; then
			region=$1
		elif [ "${1:0:1}" == "-" ]; then
			case "$1" in
			"-l")
				for name in /etc/openvpn/*.conf; do basename "$name" .conf; done | column 
				return 0;;
			"-k")
				_vpnkill
				return 0;;
			"-s")
				local proc="$(ps aux | grep openvpn | grep -v grep | head -1)"
				if [ "$proc" ]; then
					local loc=$(echo "$proc" | grep -Eo "/[A-Z].*\.")
					loc=${loc:1:-1}
					echo -n "VPN is running and connected"
					[ "$loc" ] && echo " from $loc." || echo "."
				else
					echo "VPN is not running"
				fi;;
			esac
			return 0
		else
			echo "No config file found for '$1'. Will use default option $region"
		fi
	fi
	sudo echo -n "" # Get our sudo authentication
	_vpnkill
	sudo openvpn --config $path/$region.conf >/dev/null &
	sleep 3
	alias publicip >/dev/null 2>/dev/null && publicip
}

pdfs() {
	local viewer="evince"
	if [ $# -gt 0 ]; then
		if ! [ -d "$1" ]; then
			echo "Err: Destination directory $1 not found"
			return 2
		fi
		cd "$1"
	fi
	$viewer *.pdf > /dev/null 2> /dev/null &
	if [ $# -gt 0 ]; then
		cd -
	fi

	return 0
}


pop() {
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <device>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	# Get the last argument, which should be the device's name
	for last; do true; done
	echo "Mounting $last"
	folder $last
	cd ..

	if [ $? != 0 ]; then
		echo "Error while mounting folder"
		return 1
	fi
	if ! [ -d folder ]; then
		echo "WTF? Folder not existent"
		return 1
	fi
	shift
	while [ $# -gt 1 ]; do
		cp -rvi folder/"$1" .
		shift
	done

	folder -k

	return 0
}


push() {
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <device>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	# Get the last argument, which should be the device's name
	for last; do true; done
	echo "Mounting $last"
	folder $last
	cd ..

	if [ $? != 0 ]; then
		echo "Error while mounting folder"
		return 1
	fi
	if ! [ -d folder ]; then
		echo "WTF? Folder not existent"
		return 1
	fi

	#We use 1 to skip the device's name and avoid trying to copy it
	while [ $# -gt 1 ]; do
		cp -rvi "$1" folder/
		shift
	done

	folder -k
	return 0
}

receive() {
	local usage="Usage: ${FUNCNAME[0]} <file>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }
	[ ! -e ~/Shared/$1 ] && { echo "File '$1' does not exist"; return 2; }

	local dest=.
	[[ -d $2 ]] && { dest=$2; }
	cp -r ~/Shared/$1 $dest
	return 0
}

# Not yet tested
# Had to declare it as function. 'receivedots() {' doesn't work for some reason
function receivedots {
	#TODO Argument parsing
	local keep=false
	local clone=false
	[ $1 = "-k" ] || [ $1 = "--keep" ] && {
		keep=true
		shift
	}
	[ $1 = "-c" ] || [ $1 = "--clone" ] && {
		clone=true
		shift
	}
	local cwd=".averyweirdname"
	local repo="git@github.com:ocaballeror/dotfiles.git"
	mkdir $cwd
	cd $cwd
	git clone $repo || return 1
	cd dotfiles

	$clone && return 0

	if [ ! -f "install.sh" ] || ! source install.sh; then
		for folder in *
		do
			if [ -d $folder ]; then
				#This is actually more refined and probably correct
				# case $folder in
				# 	bash) cp $folder/* ~;;
				# 	vim)  cp $folder/* ~;;
				# 	tmux) cp $folder/* ~;;
				#	nano) cp $folder/* ~;;
				# esac
				cp -r $folder/* ~
			fi
		done
	fi

	cd ../..
	keep || rm -rf $cwd
}

run(){
	local usage="Usage: ${FUNCNAME[0]} <sourcefile>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	src=$1
	if [ ! -f $src ] || [ "$(file $src | grep -w ELF)" ]; then
		src=$1.cpp
		[ ! -f $src ] && { echo "File not found"; return 2; }
	fi

	name=${src%%.*}
	ext=${src##*.}
	trap "[ -f name ] && rm $name" SIGHUP SIGINT SIGTERM
	case $ext in
		"makefile" | "Makefile") 
			make ax || make;;
		"c") 
			gcc $src -o $name && ./$name;;
		"cpp" | "cc") 
			g++ $src -o $name && ./$name;;
		"java") 
			"javac" $src && java $name;;
		"sh")
			chmod 755 $src && ./$src;;
		*) 
			echo "What the fuck is $ext in $src";;
	esac
	[ -f $name ] && rm $name
	return 0
}


scp2Phone() { 
	local usage="Usage: ${FUNCNAME[0]} <file> [destination]"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	while [ $# -gt 0 ]; do
		[ -e $1 ] && scp $1 root@192.168.1.39:/sdcard/Download
		shift
	done
}


scpFPhone() {
	local usage="Usage: ${FUNCNAME[0]} <file> [destination]"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	scp root@192.168.1.39:$1 .
}

share() {
	local usage="Usage: ${FUNCNAME[0]} <file>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	while [ $# -gt 0 ]; do
		[ -e $1 ] && cp -r $1 ~/Shared
		shift
	done
	return 0
}

sharedots() {
	trap "rm -rf $cwd 2>/dev/null; return 127;" 1 2 3 15 20
	if [ "$1" = "-vm" ] || [ "$1" = "--vm" ] || [ "$1" = "-vms" ] || [ "$1" = "--vms" ]; then
		local files=""
		for dot in bashrc bash_functions bash_aliases vimrc tmux.conf; do
			files="$files $HOME/.$dot"
		done
		for vm in Ubuntu Debian8 Debian7 Bedrock Fedora; do
			cpvm $files $vm #2>/dev/null
			[ $? == 0 ] && echo "Sharing with $vm VM..."
		done

		shift
	fi
	
	local cwd=".averyweirdname"

	# IN THEORY there shouldn't be any sudo problems when trying to commit to 
	# the git repository that's been cloned via ssh. Make sure to check this when
	# some sort of civilized internet connection is available. Oh, TODO.
	local repo="https://github.com/ocaballeror/dotfiles.git"
	mkdir $cwd
	cd $cwd
	git clone $repo || return 4
	cd dotfiles
	cp ~/.bashrc ~/.bash_aliases ~/.bash_functions bash
	cp ~/.vimrc vim
	cp ~/.tmux.conf tmux
	cp ~/.nanorc nano
	git add bash vim tmux
	git commit -m "Minor changes"
	git push
	cd ../..
	rm -rf $cwd
}

_vpnkill(){
	local reg
	for reg in $(systemctl | grep -Eo "openvpn@.*" | cut -d ' ' -f1); do
		sudo systemctl stop $reg
	done
}

vpn(){
	local path="/etc/openvpn"
	local region="UK_London"
	trap "_vpnkill 2>/dev/null; return" SIGINT SIGTERM
	if [ $# -gt 0 ]; then
		if [ -f "$path/$1.conf" ]; then
			region=$1
		elif [ "${1:0:1}" == "-" ]; then
			case "$1" in
			"-l")
				for name in /etc/openvpn/*.conf; do basename "$name" .conf; done | column 
				return 0;;
			"-k")
				_vpnkill
				return 0;;
			"-s")
				systemctl status openvpn@$region
				return 0;;
			esac
			return 0
		else
			echo "No config file found for $1. Will use default option $region"
		fi
	fi
	echo $region
	sudo echo -n "" # Get our sudo authentication
	_vpnkill 2>/dev/null
	sudo systemctl start openvpn@$region
	sleep 3
	alias publicip >/dev/null 2>/dev/null && publicip
	return 0
}

wordCount() {
	local usage="Usage: ${FUNCNAME[0]} <file>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }
	thefile=$(echo $1 | tr -d \\)
	[ ! -f "$thefile" ]  && { echo "File '$thefile' not found"; return 2; }

	temp="._temp"
	if [ "$(head -5 "$thefile" | grep -i caballero)" ] || [ "$(head -5 "$thefile" | grep -i sanz-gadea)" ]; then
		cut -d ' ' -f6- "$thefile" > "$temp"
	else
		cat "$thefile" > "$temp"
	fi
	tr -cs "A-Za-zñáéíóúÑÁÉÍÓÚ" '\n' < "$temp" | tr A-Z a-z | sort | uniq -c | sort -rn | more
	rm "$temp"
	return 0
}


# This should work too. If it doesn't, blame the function belows
xzzip(){
	local usage="Usage: ${FUNCNAME[0]} <tarfile>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }
	[ $(file $1 | grep -i "tar archive") ] && { echo "'$1' is not a valid tar file"; return 2; }

	local tarfile="$1"
	local tarname="${tarfile%%.*}"
	local zipfile="$tarname.zip"
	local tmp=".averyweirdname"

	mkdir $tmp
	tar -zxf $tarfile -C $tmp
	rm $tarfile
	cd $tmp
	if [ $(ls | wc -l) -gt 1 ]; then
		mkdir $tarname
		find . -maxdepth 1 ! -name "$tarname" -exec mv {} "$tarname" \;
	fi
	zip -r $zipfile * || return 4
	mv $zipfile ..
	cd ..
	rm -rf $tmp
}

# This should work or something right now
zipxz(){
	local usage="Usage: ${FUNCNAME[0]} <zipfile> [tar format]"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }
	[ ${1##*.} != "zip" ] && { echo "'$1' is not a valid zipfile"; return 2; }

	local zipfile=$1
	local temp=".averyweirdname"
	local tarformat
	if [ -z "$2" ]; then
		tarformat=".tar.xz"
	else
		local found=false
		for e in "gz xz bz"; do
			for f in $e .$e t$e .t$e tar$e tar.$e .tar$e .tar.$e; do
				if  "$2" = $f; then
					tarformat = "$2"
				fi
			done
		done
	fi

	local zipname="${zipfile%%.*}"
	local tarname="$zipname"."$tarformat"

	mkdir $temp
	unzip $zipfile -d $temp
	rm $zipfile
	cd $temp
	if [ $(ls | wc -l) -gt 1 ]; then
		mkdir $zipname
		mv !($zipname) $zipname
	fi
	tar -cvf $tarname * || return 4
	mv $tarname ..
	cd ..
	rm -rf $temp
}
