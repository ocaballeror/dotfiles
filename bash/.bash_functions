#!/bin/bash
# Theoretically, this should be the return codes:
#	0 - Everything went as planned
#	1 - There was an error in the arguments (unsufficient, mistyped...)
#	2 - Referenced files or directories do not exist
#	3 - Other
#
#	THIS IS STILL NOT CONSISTENT, THOUGH. RETURN CODES SHOULDN'T BE TRUSTED YET
#
#	THIS IS A BIG TO-DO. DON'T BE SO LAZY AND ACTUALLY DO SOME WORK YOU LAZY ASS PRICK


# Cd to any of the last 10 directories in your history with 'cd -Number'. Use 'cd --' to see the history
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

# Finds a vm in any of $VBOXHOME or $VMWARE and stores its path in the variable vm
_findvm() {
	if  ( [ -z "$VBOXHOME" ]   || [ ! -d "$VBOXHOME" ]  ) &&\
	    ( [ -z "$VMWAREHOME" ] || [ ! -d "$VMWAREHOME" ]) &&\
		( [ ! -d /ssd  ] ); then
		>&2 echo "Err: Could not find the VMs folder. Check that the enviromental variables
		\$VBOXHOME or \$VMWAREHOME are set and point to valid paths"
		return 3
	fi

	local vmpath vmhome
	if [ "$1" = "vb" ]; then
		vmhome="$VBOXHOME"
		if [ -z "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VBOXHOME is not set"
			return 1
		elif [ ! -d "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VBOXHOME doesn't point to a valid directory"
			return 1
		fi
		shift
	elif [ "$1" = "vw" ]; then
		vmhome="$VMWAREHOME"
		if [ -z "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VMWAREHOME is not set"
			return 1
		elif [ ! -d "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VMWAREHOME doesn't point to a valid directory"
			return 1
		fi
		shift
	else
		local opt
		for opt in "$VBOXHOME" "$VMWAREHOME" /ssd; do
			[ -n "$opt" ] && [ -d "$opt" ] && vmhome+="$opt "
		done
	fi

	[ $# -lt 1 ] && return 1

	if [ -z "$vmhome" ]; then
		>&2 echo "Err: No VM home folder specified and the default ones could not be found"
		return 2
	fi


	local vmname="$1"

	found=false
	for vmpath in $vmhome; do
		if [ -n "$vmpath" ] && [ -d "$vmpath" ]; then
			if [ ! -d "$vmpath/$vmname" ]; then
				# Try to correct spelling errors. Usually the case-sensitivity will be fixed with this
				local ivmname=$(find $vmpath -maxdepth 1 -type d | grep -Fi $vmname | head -1)
				if [ -n "$ivmname" ] && [ -d "$ivmname" ]; then
					vm="$ivmname"
					return 0
				else
					continue
				fi
			else
				vm="$vmpath/$vmname"
				return 0
			fi
		else
			continue
		fi

	done
	
	>&2 echo "Err: '$1' is not a vm"
	return 2
}

# Cd into a VM located in my VMs folder. Requires VBOXHOME or VMWAREHOME to be set (see .bashrc)
# Examples:
# $ cdvm arch           # Find a vm folder called arch in any of the VM home folders
# $ cdvm vb ubuntu      # Find a virtualbox vm called ubuntu
# $ cdvm vw             # Cd to the home directory of vmware
cdvm() {
	local usage="Usage: ${FUNCNAME[0]} [vb|vw] [VMName]"

	local vmpath
	if [ "$1" = "vb" ]; then
		vmpath="vb"
	   	shift 
	elif [ "$1" = "vw" ]; then
		vmpath="vw"
		shift
	fi

	# If the user didn't specify anything, try to at least cd into the home vm directory
	if [ $# -lt 1 ]; then
		# Allow the user to only pass 'vb' or 'vw' as a parameter to cd into the home vm directory of those
		if [ -z $vmpath ]; then
			if [ -n "$VBOXHOME" ] && [ -d "$VBOXHOME" ]; then
				cd "$VBOXHOME"
			else
				if [ -n "$VMWAREHOME" ] && [ -d "$VMWAREHOME" ]; then
					cd "$VMWAREHOME"
				else
					>&2 echo "No parameters passed and enviromental variables aren't set properly"
					return 1
				fi
			fi
		else
			if [ $vmpath = "vb" ] && [ -n "$VBOXHOME" ] && [ -d "$VBOXHOME" ]; then
				cd "$vmpath" 
			elif [ $vmpath = "vw" ] && [ -n "$VMWAREHOME" ] && [ -d "$VMWAREHOME" ]; then
				cd "$vmpath"
			else
				>&2 echo "Err: '$1' is not a valid identifier for a VM home folder"
				return 1
			fi
			return 0
		fi
	fi

	# It doesn't matter if vmpath is not set
	_findvm $vmpath $1
	local ret=$?
	[ $ret = 0 ] && cd "$vm"

	return $ret
}


# Obtains the source code of a program in Arch Linux
code(){
	local force=false
	[ $1 == "-f" ] && { force=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <Program> [destination]"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	if ! $force && hash yaourt 2> /dev/null; then
		if [ "$(yaourt -Ssq $1 | grep -E "^$1$")" ]; then
			[ "$target" ] && cd $target
			yaourt -G $1
			cd $1

			[ -f PKGBUILD ] || return 2
			makepkg -od
			[ -d src ] && cd src/
		else
			echo "Program '$1' not found in repos"
			return 2
		fi
	else # I guess we'll have to do it the pacman way. That is, with sudo commands
		local repo=$(pacman -Ss $1  | grep -E ".*/$1 .*[0-9]+[\.[0-9]*|\-[0-9]]+" | cut -d / -f1)
		if [ "$repo" ]; then
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
}


# Compare 2 or 3 files and open a diffviewer if they are different
comp(){
	_comp_junk $* 2>/dev/null
}

_comp_junk() {
	if [ $1 = "-m" ]; then 
		local difview=$2
		if hash $difview 2>/dev/null; then 
			shift 2 
		else
			echo "Program '$2' is not installed"
			return 2
		fi
	fi

	local usage="Usage: ${FUNCNAME[0]} <list-of-files>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }
	for name in $*; do [ ! -f $name ] && { echo "File '$name' does not exist"; return 2; }; done

	if [ -z $difview ]; then
		for dif in vimdiff meld colordiff diff cmp; do
			if hash $dif 2>/dev/null; then
				difview=$dif
				break
			fi
		done
	fi

	[ -z $difview ] && { echo "Couldn't find a diff viewing program. Please specify it with -m"; return 3; }

	local changed=false
	while [ $# -ge 2 ]; do
		if [ $(($# % 2)) = 0 ]; then
			$(cmp -s "$1" "$2") || { changed=true; $difview "$1" "$2"; }
			shift 2
		elif [ $# = 3 ]; then 
			# Results in this order: all equal, 3 is different, 1 is different, 2 is different, all are different
			$(cmp -s "$1" "$2")\
				&&  ($(cmp -s "$1" "$3") && continue || $difview "$1" "$3")\
				||  ($(cmp -s "$2" "$3") && $difview "$1" "$2" ||\
				($(cmp -s "$1" "$3") && $difview "$1" "$2" || $difview "$1" "$2" "$3"))
			changed=true
			shift 3
		fi
	done

	$changed || echo "Nothing to see here"
	[ $# = 1 ] && { echo "Couldn't handle last argument '$1'"; return 4; }
	return 0
}


# Copy and cd
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


# BUG Not working properly when vmname is the first argument
# Copies files to the specified VM located in my VMs folder. Saves me a few keystrokes from time to time 
cpvm() {
	# Quite a hacky way to do things, but it does the job
	local switches="rv" # The only default switch
	while [[ $1 =~ -.* ]]; do
		local newswitch=${1##*-}
		[ ! "$(echo $switches | grep $newswitch)" ] && { switches+=$newswitch; } # Eliminate duplicates
		shift
	done

	# And now that we have our cp switches, parse the arguments as normal
	local usage="Usage: ${FUNCNAME[0]} [copyopts] <files> <VMName>
	OR ${FUNCNAME[0]} [copyopts] <VMName> <files>"

	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	if  ( [ -z "$VBOXHOME" ]   || [ ! -d "$VBOXHOME" ]  ) &&\
	    ( [ -z "$VMWAREHOME" ] || [ ! -d "$VMWAREHOME" ]); then
		echo "Err: Could not find the VMs folder. Check that the enviromental variables
		\$VBOXHOME or \$VMWAREHOME are set and point to valid paths"
		return 3
	fi

	local vmpath vm vmhome
	if [ "$1" = "vb" ]; then
		vmhome="vb"
		shift
	elif [ "$1" = "vw" ]; then
		vmhome="vw"
		shift
	fi

	# Obtain the last argument passed
	for last; do true; done

	# Try to flip the arguments. See if the first or the last argument are valid vms
	local target ret
	local flipped=false
	_findvm $vmhome $2 
	ret=$?
	if [ $ret = 0 ]; then
		local target="$vm/Shared"
	elif [ $ret -lt 3 ]; then
		_findvm $vmhome $last
		local ret=$?
		if [ $ret = 0 ]; then
			flipped=true
			target="$vm/Shared"
		else
			return $ret	
		fi
	elif [ $ret -ge 3 ]; then
		return $ret #An error message should have been printed already
	fi

	# If we found the vm folder, but there's not a subfolder called 'Shared'
	if [ ! -d $target ]; then
		echo "W: Had to create the folder called Shared. The folder sharing mechanism may not be set up"
		mkdir "$target"
	fi

	#We should have at least the -r switch right now.
	cmmd="cp -$switches " #Notice the blank space at the end
	if ! $flipped; then 
		while [ $# -gt 1 ]; do
			if [ ! -e "$1" ]; then
			   	>&2 echo "Err: Source file '$src' does not exist"
				return 2
			fi
			cmmd+="$1 "
			shift
		done
	else
		while [ $# -ge 2 ]; do
			if [ ! -e "$2" ]; then
			   	>&2 echo "Err: Source file '$src' does not exist"
				return 2
			fi
			cmmd+="$2 "
			shift
		done
	fi

	( $cmmd $target )

	return 0
}


#TEST
# Calculates the sum of a file and compares it with the one provided. Works with a few popular algorithms
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


# Loads my configuration of gdrivefs and mounts my GDrive in a system folder
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


#TEST
# Dump the contents of a folder into the cwd and delete it afterwards. Accepts a destination path as an argument
dump() {
	[ "$1" = "-a" ] && { aggressive=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <dir>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	local cwd="$(pwd)"
	if [ $1 != '.' ]; then
		if [ ! -d "$1" ]; then
			echo "Err: The specified path does not exist"
			return 1
		fi
		cd $1
	fi

	local file
	for file in **/*; do
		if $aggressive; then
			mv $file .
		else
			if [ -e $file ]; then 
				local dest="$(dirname $(dirname "$file"))"
				[ "$(readlink -f $dest)" = "$(readlink -f ..)" ] && dest=. # Keep everything in the folder we're dumping.
				mv -v "$file" "$dest" 2> /dev/null
			fi
		fi
	done

	$moved && { cd -; }

	return 0
}


# Unmount a device and mount it in a local folder called "folder"
folder() {
	_cleanup() {
		sudo umount $1
		if [ $? != 0 ]; then
			echo "W: Couldn't unmount $1"
		else
			rmdir $1 2>/dev/null
		fi
	}
	local usage="Usage: ${FUNCNAME[0]} [-o <folder>] <-k|device>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	if [ "$1" = "-o" ]; then
		[ -z "$2" ] && { printf "No folder name provided\n$usage"; return 1; }	
		local folder="$2"
		shift 2
	else
		local folder="folder"
	fi

	# If we consumed all the arguments already, it means no device name has been passed
	[ $# -lt 1 ] && { echo "$usage"; return 1; }

	#Best argument parsing ever
	if [ $1 = "-k" ] || [ $1 = "kill" ]; then
		
		# If the mountpoint was passed to -k as a parameter use it. Otherwise we'll have to guess what the mountpoint is
		if [ -n $2 ]; then
			[ ! -d $2 ] && { echo "The argument given is not a folder"; return 1; }
			if ! grep -qs $2 /proc/mounts; then
				echo "The argument given to -k is not a mountpoint"
			else
				_cleanup $2
				return 0
			fi
		else
			folder="$(readlink -f $folder)"
			if [ ! -d "$folder" ] || [ -z "$(df $folder)" ]; then

				# Get the first parent for this folder that is a mountpoint
				local mp="$(df --output=target . | tail -1)"

				# Try to guess if we're inside the mounted folder
				if $(echo "$mp" | grep -Eq ".*/$folder(/.*|$)"); then
					cd "$(dirname "$mp")" #Jump up to our mountpoint
					folder="$mp" #Change the folder we will umount down below
				else
					echo "Err: No parent mountpoint or it's not one of our own."
					mp="$(df --output=target | grep -E "$folder$" | tail -1)"
					if [ $mp ]; then
						local opt
						if [ "$2" != '-f' ]; then
							local src=$(df --output=source $mp | tail -1)
							local fstype=$(df --output=fstype $mp | tail -1)
							echo -n "Do you want to risk it and unmount $src [$fstype] from $mp? (y/N): "
							read opt
						else
							opt='y'
						fi
						if [ $opt = 'y' ]; then
							sudo umount $mp 
						else
							echo "Aborted."
						fi
						return 0
					else
						return 3
					fi
				fi
			fi

			_cleanup $folder
		fi
		return 0
	fi


	# Regular expression that will allow us things like 'folder d1' to match /dev/sd1
	local dXY="^[a-z][0-9]*$"
	local device

	if [[ $1 =~ $dXY ]]; then
		device="/dev/sd$1"
	elif [ -b "/dev/$1" ]; then
		device="/dev/$1"
	elif [ -b "$1" ]; then
		device="$1"
	fi

	if ! [ -b $device ]; then
		echo "Err: Device '$device' does not exist"
		return 2
	else
		if grep -qs $device /proc/mounts; then
			sudo umount $device
			if [ $? != 0 ]; then
				echo "Err: There was an error unmounting $device. Close any application that may be using it and try again"
				return 2;
			fi
		fi

		if ! [ -d "$folder" ]; then
			mkdir "$folder"
		fi

		sudo mount -o rw $device "$folder"
		if [ $? != 0 ]; then
			echo "Err: Could not mount $device"
			rmdir "$folder"
			return 3
		fi
	fi
	#	cd "$folder"

	return 0
}


# TODO Make it count lines of non-code text files as well
# Count the lines of code in the current directory and subdirectories
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
		extensions=( c cpp h hpp S asm java js clp hs py pl sh cs css cc html htm sql rb el)
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


#Download from youtube and convert to mp3
mp3(){
	local usage="Usage: ${FUNCNAME[0]} <url>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	youtube-dl $1 -x --audio-format mp3 --audio-quality 0
}


#TEST
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


oldvpn() {
	_oldvpnkill () {
		[ "$(ps aux | grep openvpn | grep -v grep)" ] && sudo pkill -9 openvpn
	}

	local path="/etc/openvpn"
	local region="UK_London"
	trap "_oldvpnkill; return" SIGINT SIGTERM
	if [ $# -gt 0 ]; then
		if [ -f "$path/$1.conf" ]; then
			region=$1
		elif [ "${1:0:1}" == "-" ]; then
			case "$1" in
				"-l")
					for name in /etc/openvpn/*.conf; do
						basename "$name" .conf
					done | column 
					return 0;;
				"-k")
					_oldvpnkill
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
	_oldvpnkill
	sudo openvpn --config $path/$region.conf >/dev/null &
	[ $? = 0 ] || return 2
	sleep 3
	alias publicip >/dev/null 2>/dev/null && publicip
	unset -f _oldvpnkill
	return 0
}


pdfs() {
	local viewer="evince"
	if [ $# -gt 0 ]; then
		if ! [ -d "$1" ]; then
			echo "Err: Destination directory $1 not found"
			return 2
		fi
		pushd .
	fi
	$viewer *.pdf > /dev/null 2> /dev/null &
	if [ $# -gt 0 ]; then
		popd
	fi

	return 0
}


# Mounts a disk, copies a set of files from it and then unmounts it
pop() {
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <device>"
	if [ $# -lt 2 ]; then
		echo "$usage"
		return 1
	fi

	local folder="$(mktemp -d)"

	# Get the last argument, which should be the device's name
	local dev
	for dev; do true; done

	# Regular expression that will allow us things like 'push <file> d1' to match /dev/sd1
	local dXY="^[a-z][0-9]*$"

	if [[ $dev =~ $dXY ]]; then
		device="/dev/sd$dev"
	elif [ -b "/dev/$dev" ]; then
		device="/dev/$dev"
	elif [ -b "$dev" ]; then
		device="$dev"
	fi

	# Mount the device
	if ! [ -b $device ]; then
		echo "Err: Device '$device' does not exist"
		return 2
	else
		if grep -qs $device /proc/mounts; then
			sudo umount $device
			if [ $? != 0 ]; then
				echo "Err: There was an error unmounting $device. Close any application that may be using it and try again"
				rm -rf "$folder"
				return 2;
			fi
		fi

		sudo mount -o rw $device "$folder"
		if [ $? != 0 ]; then
			echo "Err: Could not mount $device"
			rm -rf "$folder"
			return 3
		fi
	fi


	# Copy stuff to the mounted folder
	# We use 1 to skip the device's name and avoid trying to copy it to itself
	while [ $# -gt 1 ]; do
		if ! [ -e "$folder/$1" ]; then
			echo "W: File '$folder/$1' does not exist"
		else
			cp -r "$folder/$1" . >/dev/null 2>&1
			if [ $? != 0 ]; then
				echo "W: File '$1' could not be copied"
			else
				echo "Copied '$1'"
			fi
		fi
		shift
	done

	# Done copying, unmount the device
	sudo umount $device
	if [ $? != 0 ]; then
		echo "W: There was an error unmounting $device. Close any application that may be using it and try again"
	fi
	rm -rf "$folder"

	return 0
}


# Mounts a disk, copies a set of files into it and then unmounts it.
push() {
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <device>"
	if [ $# -lt 2 ]; then
		echo "$usage"
		return 1
	fi

	local folder="$(mktemp -d)"

	# Get the last argument, which should be the device's name
	local dev
	for dev; do true; done

	# Regular expression that will allow us things like 'push <file> d1' to match /dev/sd1
	local dXY="^[a-z][0-9]*$"

	if [[ $dev =~ $dXY ]]; then
		device="/dev/sd$dev"
	elif [ -b "/dev/$dev" ]; then
		device="/dev/$dev"
	elif [ -b "$dev" ]; then
		device="$dev"
	fi

	# Mount the device
	if ! [ -b $device ]; then
		echo "Err: Device '$device' does not exist"
		return 2
	else
		if grep -qs $device /proc/mounts; then
			sudo umount $device
			if [ $? != 0 ]; then
				echo "Err: There was an error unmounting $device. Close any application that may be using it and try again"
				rm -rf "$folder"
				return 2;
			fi
		fi

		sudo mount -o rw $device "$folder"
		if [ $? != 0 ]; then
			echo "Err: Could not mount $device"
			rm -rf "$folder"
			return 3
		fi
	fi


	# Copy stuff to the mounted folder
	# We use 1 to skip the device's name and avoid trying to copy it to itself
	while [ $# -gt 1 ]; do
		if ! [ -e "$1" ]; then
			echo "W: File '$1' does not exist"
		else
			cp -r "$1" "$folder" >/dev/null 2>&1
			if [ $? != 0 ]; then
				echo "W: File '$1' could not be copied"
			else
				echo "Copied '$1'"
			fi
		fi
		shift
	done

	# Done copying, unmount the device
	sudo umount $device
	if [ $? != 0 ]; then
		echo "W: There was an error unmounting $device. Close any application that may be using it and try again"
	fi
	rm -rf "$folder"

	return 0
}


#TEST
# Had to declare it as function. 'receivedots() {' doesn't work for some reason
# Clones my dotfiles repository and copies every file to their respective directory
function receivedots {
	_dumptohome(){
		cp -r "$1/.*" "$HOME" 2>/dev/null
	}

	local keep=false
	local clone=false
	if [ $1 = "-k" ] || [ $1 = "--keep" ]; then
		keep=true
		shift
	fi
	if [ $1 = "-c" ] || [ $1 = "--clone" ]; then
		clone=true
		shift
	fi
	local cwd="$(readlink -f .)"
	local wd=".averyweirdname"
	local repo="git@github.com:ocaballeror/dotfiles.git"
	mkdir $wd
	cd $wd
	git clone $repo || return 1
	cd dotfiles

	$clone && return 0

	if [ ! -f "install.sh" ] || ! source install.sh; then
		for folder in *; do
			if [ -d $folder ]; then
				case $folder in
					bash)   _dumptohome "$folder";;
					vim)    _dumptohome "$folder";; 
					tmux)   _dumptohome "$folder";; 
					nano)   _dumptohome "$folder";; 
					zsh)    _dumptohome "$folder";; 
					ranger) _dumptohome "$folder";; 
				esac
			fi
		done
	fi

	cd $cwd 
	keep || rm -rf $wd
}


#TEST java
# Compile and run any c, cpp, java (may not work) or sh file.
run(){
	local usage="Usage: ${FUNCNAME[0]} <sourcefile>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	src=$1
	if [ ! -f $src ] || [ "$(file $src | grep -w ELF)" ]; then
		src=$1.cpp
		if [ ! -f $src ]; then
		   	echo "File not found"
			return 2
		fi
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


#TEST 
# Add, commit and push all my dotfiles 
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


# Swap two files. Rename $1 to $2 and $2 to $1
swap() {
	local usage="Usage: ${FUNCNAME[0]} <file1> <file2>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	[ ! -e "$1" ] &&  { echo "File $1 does not exist"; return 2; }
	[ ! -e "$2" ] &&  { echo "File $2 does not exist"; return 2; }

	local tmp=$(mktemp -d)
	mv "$1" "$tmp" >/dev/null
	mv "$2" "$1" >/dev/null
	mv "$tmp/$1" "$2" >/dev/null
	rm -rf $tmp >/dev/null
}


# Activate a vpn at the specified location. Requires openvpn to be properly configured and a username and password to be set
vpn(){
	function _vpnkill {
		local reg
		for reg in $(systemctl | grep -Eo "openvpn-client@.*" | cut -d ' ' -f1); do
			sudo systemctl stop $reg
			echo "Stopped vpn at $reg"
		done
	}
	local path="/etc/openvpn"
	local region="UK_London"
	trap "_vpnkill 2>/dev/null; return" SIGINT SIGTERM
	if [ $# -gt 0 ]; then
		if [ -f "$path/$1.conf" ]; then
			region=$1
		elif [ "${1:0:1}" = "-" ]; then
			case "$1" in
				"-l")
					for name in /etc/openvpn/client/*.conf; do
						basename "$name" .conf;
					done | column 
					return 0;;
				"-k")
					_vpnkill
					return 0;;
				"-s")
					systemctl status openvpn-client@$region
					return 0;;
			esac
			return 0
		else
			echo "No config file found for $1. Will use default option $region"
		fi
	fi
	echo "Starting VPN to $region"
	sudo echo -n "" # Get our sudo authentication
	_vpnkill 2>/dev/null
	sudo systemctl start openvpn-client@$region
	[ $? = 0 ] || return
	sleep 3
	alias publicip >/dev/null 2>/dev/null && publicip
	unset -f _vpnkill
	return 0
}

# Show a sorted list of the most used words in a document
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


#TEST 
# This should work too. If it doesn't, blame the function belows
# Convert tar archives to zip
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


#TEST 
# This should work or something right now
# Convert zips to tarxz
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
		find . -maxdepth 1 ! -name "$zipname" -exec mv {} "$zipname" \;
	fi
	tar -cvf $tarname * || return 4
	mv $tarname ..
	cd ..
	rm -rf $temp
}
