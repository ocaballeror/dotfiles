#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	hash wget >/dev/null || skip "Wget not installed"

	temp=$(mktemp -d)
	pushd . >/dev/null
	cd $temp
}

teardown() {
	popd >/dev/null
	rm -rf $temp
}

@test "Basic mp3" {
skip
	filename=test

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO $filename.wav || skip "Audio file not available"
	[ -s "$filename.wav" ] || skip "Audio file not available"

	run mp3 $filename.wav

	[ -s $filename.mp3 ]
	file $filename.mp3 | grep -qi "layer III"
}

@test "Mp3 remove originals" {
skip
	filename=test

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO $filename.wav || skip "Audio file not available"
	[ -s "$filename.wav" ] || skip "Audio file not available"

	run mp3 -r $filename.wav

	[ -s $filename.mp3 ]
	file $filename.mp3 | grep -qi "layer III"
}

@test "Mp3 with multiple files" {
skip
	file1=test
	file2=test2

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO $file1.wav || skip "Audio file not available"
	[ -s "$file1.wav" ] || skip "Audio file not available"
	cp $file1.wav $file2.wav
	
	run mp3 *

	[ -s $file1.mp3 ]
	file $file1.mp3 | grep -qi "layer III"

	[ -s $file2.mp3 ]
	file $file2.mp3 | grep -qi "layer III"
}

@test "Mp3 with multiple filenames with spaces" {
skip
	file1="test file"
	file2="test file2"

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO "$file1.wav" || skip "Audio file not available"
	[ -s "$file1.wav" ] || skip "Audio file not available"

	cp "$file1.wav" "$file2.wav"
	run mp3 *

	[ -s "$file1.mp3" ]
	file "$file1.mp3" | grep -qi "layer III"

	[ -s "$file2.mp3" ]
	file "$file2.mp3" | grep -qi "layer III"
}

@test "Mp3: Multiple files, multiple formats, spaces, remove originals" {
skip
	file1="test file"
	file2="test file2"

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO "$file1.wav" || skip "Audio file not available"
	[ -s "$file1.wav" ] || skip "Audio file not available"

	cp "$file1.wav" "$file2.wav"
	run mp3 -r *

	[ -s "$file1.mp3" ]
	file "$file1.mp3" | grep -qi "layer III"

	[ -s "$file2.mp3" ]
	file "$file2.mp3" | grep -qi "layer III"
}

@test "Mp3 multiprocessing" {
skip
	nfiles=25
	# wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_96k_-3dBFS_lin.wav'\
	#    	-qO "test file1.wav" || skip "Audio file not available"
	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdsweep_1Hz_96000Hz_-3dBFS_30s.wav'\
	   	-qO "file1.wav" || skip "Audio file not available"
	[ -s "file1.wav" ] || skip "Audio file not available"

	for i in `seq 2 $nfiles`; do
		cp "file1.wav" "file$i.wav"
	done

	run mp3 * &
	pid=$!
	sleep .1
	process=$(pgrep -P $pid)
	children=$(pgrep -P $process)
	nchildren=$(echo "$children" | wc -l)
	[ $nchildren -ge 1 ]

	wait $pid

	for i in `seq 1 $nfiles`; do
		[ -s "file$i.mp3" ]
	done
}

@test "Mp3 multiprocessing interrupt" {
	nfiles=25
	# wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_96k_-3dBFS_lin.wav'\
	#    	-qO "test file1.wav" || skip "Audio file not available"
	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdsweep_1Hz_96000Hz_-3dBFS_30s.wav'\
	   	-qO "test file1.wav" || skip "Audio file not available"
	[ -s "test file1.wav" ] || skip "Audio file not available"

	for i in `seq 2 $nfiles`; do
		cp "test file1.wav" "test file$i.wav"
	done

	run mp3 * &
	pid=$!
	sleep .1
	children="$(pgrep -P $pid)"
	[ "$(echo "$children" | wc -l)" -ge 1 ]

	kill -2 $pid
	wait
	for child in $children; do
		! ps hp $child >/dev/null
	done

	first=$(ls -1 *mp3 | head -1)
	fsize=$(stat -c %s "$first")
	ls -lh # Just for error messages in case the test fails

	find . -name "*mp3" -exec bash -c '
	for mp3 do
		[ -s "$mp3" ] && [ $(stat -c "%s" "$mp3") = "$1" ];
	done;' find-sh $fsize {} +
}
