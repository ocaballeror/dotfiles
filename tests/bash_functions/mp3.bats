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
	filename=test

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO $filename.wav || skip "Audio file not available"
	run mp3 $filename.wav
	[ -f $filename.mp3 ]
	[ -s $filename.mp3 ]
	file $filename.mp3 | grep -qi "layer III"
}

@test "Mp3 removing original files" {
	filename=test

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO $filename.wav || skip "Audio file not available"
	run mp3 -r $filename.wav
	[ -f $filename.mp3 ]
	[ -s $filename.mp3 ]
	file $filename.mp3 | grep -qi "layer III"
}

@test "Mp3 with multiple files" {
	file1=test
	file2=test2

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO $file1.wav || skip "Audio file not available"
	cp $file1.wav $file2.wav
	
	run mp3 *

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

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO "$file1.wav" || skip "Audio file not available"
	cp "$file1.wav" "$file2.wav"
	
	run mp3 *

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

	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_88k_-3dBFS_lin.wav'\
	   	-qO "$file1.wav" || skip "Audio file not available"
	cp "$file1.wav" "$file2.wav"
	
	run mp3 -r *

	[ -f "$file1.mp3" ]
	[ -s "$file1.mp3" ]
	file "$file1.mp3" | grep -qi "layer III"

	[ -f "$file2.mp3" ]
	[ -s "$file2.mp3" ]
	file "$file2.mp3" | grep -qi "layer III"
}

@test "Mp3 multiprocessing" {
	nfiles=25
	# wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_96k_-3dBFS_lin.wav'\
	#    	-qO "test file1.wav" || skip "Audio file not available"
	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdsweep_1Hz_96000Hz_-3dBFS_30s.wav'\
	   	-qO "test file1.wav" || skip "Audio file not available"

	for i in `seq 2 $nfiles`; do
		cp "test file1.wav" "test file$i.wav"
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
		[ -f "test file$i.mp3" ]
		[ -s "test file$i.mp3" ]
	done
}

@test "Mp3 multiprocessing interrupt" {
	nfiles=25
	# wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdchirp_96k_-3dBFS_lin.wav'\
	#    	-qO "test file1.wav" || skip "Audio file not available"
	wget 'http://www.audiocheck.net/download.php?filename=Audio/audiocheck.net_hdsweep_1Hz_96000Hz_-3dBFS_30s.wav'\
	   	-qO "test file1.wav" || skip "Audio file not available"

	for i in `seq 2 $nfiles`; do
		cp "test file1.wav" "test file$i.wav"
	done

	run mp3 * &
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
