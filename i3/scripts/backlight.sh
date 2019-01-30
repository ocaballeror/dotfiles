# !/bin/bash

# Set brightness on my stupid laptop that doesn't seem to work with xbacklight for some reason
# Still requires root
backlight(){
	local usage="Usage: ${FUNCNAME[0]} <brightness>.
You can specify relative values using '+' and '-' signs before number and/or percentages appending '%' to the number. For example:

Set brightness to 300
${FUNCNAME[0]} 300

Set brightness to 50%
${FUNCNAME[0]} 50%

Increase brightness by 50
${FUNCNAME[0]} +50

Decrease brightness by 10%
${FUNCNAME[0]} -10%
"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	local value=$1

	local relative=false
	local sign=""
	local percentage=false
	if [ ${1:0:1} = "+" ] || [ ${1:0:1} = "-" ]; then
		relative=true
		sign=${value:0:1}
		value=${value:1}
	fi

	local length=$((${#value} - 1))
	local lastpos=${value:$length}
	if [ $lastpos = "%" ]; then
		percentage=true
		value=${value:0:$length}
	fi

	local re='^[0-9]*$'
	if ! [[ $value =~ $re ]]; then
		if [ $value != "max" ]; then
			echo "Err: '$value' is not a number"
			return 1
		fi
	fi

	local path="/sys/class/backlight/intel_backlight"
	[ ! -d $path ] && { echo "Err: Couldn't access path '$path'"; return 2; }
	for filename in max_brightness actual_brightness; do
		if [ ! -f $path/$filename ]; then
			echo "Err: Couldn't find file $filename"
			return 2
		fi
	done

	local bright
	local maxb=$(cat $path/max_brightness)
	if $relative; then
		local current=$(cat $path/actual_brightness)
		if $percentage; then
			bright=$(echo "scale=2; ($current $sign (($value*$maxb)/100))" | bc)
			bright=${bright%%.*}
		else
			bright=$(($current $sign $value))
		fi
	else
		if $percentage; then
			bright=$(echo "scale=2; ($value * $maxb) / 100" | bc)
			bright=${bright%%.*}
		else
			if [ $value = "max" ]; then
				bright=$maxb
			elif [ $value -gt $maxb ]; then
				echo "W: Brightness will be set to max brightness $maxb"
				bright=$maxb
			else
				bright=$value
			fi
		fi
	fi

	[ $bright -gt $maxb ] && bright=$maxb
	[ $bright -lt 0 ]     && bright=0

	echo "Brightness set to $bright / $maxb"
	sudo tee $path/brightness <<< $bright >/dev/null
}

backlight $*
