#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	for dep in wget ffmpeg; do
		hash "$dep" >/dev/null || skip "$dep not installed"
	done

	tmpfile=".${BATS_TEST_FILENAME//\//_}_tmp"
	if [ "$BATS_TEST_NUMBER" = 1 ]; then
		global_tmp=$(mktemp -d)
		echo "$global_tmp" > "$tmpfile"
		if ! [ -f "$global_tmp/small_wav.wav" ]; then
			wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
				-qO "$global_tmp/small_wav.wav" || skip "Audio file not available"
		fi
		if ! [ -f "$global_tmp/big_wav.wav" ]; then
			wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdsweep_1Hz_96000Hz_-3dBFS_30s.wav'\
				-qO "$global_tmp/big_wav.wav" || skip "Audio file not available"
		fi
	else
		global_tmp=$(cat "$tmpfile")
	fi

	temp=$(mktemp -d)
	pushd . >/dev/null
	cd $temp
	cp "$global_tmp/small_wav.wav" .
	cp "$global_tmp/big_wav.wav" .
}

teardown() {
	popd >/dev/null
	rm -rf $temp

	if [ "$BATS_TEST_NUMBER" -eq ${#BATS_TEST_NAMES[@]} ]; then
		tmpfile=".${BATS_TEST_FILENAME//\//_}_tmp"
		global_tmp=$(cat "$tmpfile")
		rm -rf "$global_tmp" "$tmpfile"
	fi
}

@test "Basic mp3" {
	filename="small_wav"

	ls
	mp3 $filename.wav
	ls
	[ -f $filename.mp3 ]
	[ -s $filename.mp3 ]
	file $filename.mp3 | grep -qi "layer III"
}

@test "Mp3 removing original files" {
	filename="small_wav"

	mp3 -r $filename.wav
	[ -f $filename.mp3 ]
	[ -s $filename.mp3 ]
	file $filename.mp3 | grep -qi "layer III"
}

@test "Mp3 with multiple files" {
	file1="small_wav"
	file2="small_wav2"

	cp $file1.wav $file2.wav
	mp3 *.wav

	[ -f $file1.mp3 ]
	[ -s $file1.mp3 ]
	file $file1.mp3 | grep -qi "layer III"

	[ -f $file2.mp3 ]
	[ -s $file2.mp3 ]
	file $file2.mp3 | grep -qi "layer III"
}

@test "Mp3 with multiple filenames with spaces" {
	file1="test file"
	file2="test file2"

	mv "small_wav.wav" "$file1.wav"
	cp "$file1.wav" "$file2.wav"
	mp3 *.wav

	[ -f "$file1.mp3" ]
	[ -s "$file1.mp3" ]
	file "$file1.mp3" | grep -qi "layer III"

	[ -f "$file2.mp3" ]
	[ -s "$file2.mp3" ]
	file "$file2.mp3" | grep -qi "layer III"
}

@test "Mp3: Multiple files, multiple formats, spaces, remove originals" {
	file1="test file"
	file2="test file2"

	mv "small_wav.wav" "$file1.wav"
	cp "$file1.wav" "$file2.wav"
	mp3 -r *

	[ -f "$file1.mp3" ]
	[ -s "$file1.mp3" ]
	file "$file1.mp3" | grep -qi "layer III"

	[ -f "$file2.mp3" ]
	[ -s "$file2.mp3" ]
	file "$file2.mp3" | grep -qi "layer III"
}

@test "Mp3 multiprocessing" {
	nfiles=25

	mv "big_wav.wav" "test file1.wav"
	for i in `seq 2 $nfiles`; do
		cp "test file1.wav" "test file$i.wav"
	done

	mp3 * &
	pid=$!
	sleep .1
	process=$(pgrep -P $pid)
	children=$(pgrep -P $process)
	nchildren=$(echo "$children" | wc -l)
	[ $nchildren -ge 1 ]

	wait $pid

	for i in `seq 1 $nfiles`; do
		[ -f "test file$i.mp3" ]
		[ -s "test file$i.mp3" ]
	done
}

@test "Mp3 multiprocessing interrupt" {
	nfiles=25

	mv "big_wav.wav" "test file1.wav"
	for i in `seq 2 $nfiles`; do
		cp "test file1.wav" "test file$i.wav"
	done

	mp3 * &
	pid=$!
	sleep .1
	process=$(pgrep -P $pid)
	children=$(pgrep -P $process)
	nchildren=$(echo "$children" | wc -l)
	[ $nchildren -ge 1 ]
	kill -2 $process

	for child in $children; do
		! ps hp $child >/dev/null
	done


	for file in *mp3; do
		[ -s "$file" ]
	done
}
