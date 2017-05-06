load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	test1="$(mktemp)"
	test2="$(mktemp)"
	test3="$(mktemp)"
	cd $temp

	echo "test 1" > $test1
	echo "test 2" > $test2
	echo "test 3" > $test3
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
}

@test "Comp different files" {
	comp $test1 $test2
	# sleep 2
	run bash -c "ps aux | grep vimdiff $test1 $test2 | grep -v grep"
	[ $status = 0 ]
	kill "$(echo "$output" | awk '{print $2}')"
}

@test "Comp equal files" {
	echo "test 1" > $test1
	echo "test 1" > $test2
	comp $test1 $test2
	# sleep 2
	run bash -c "ps aux | grep vimdiff $test1 $test2 | grep -v grep"
	[ $status = 1 ]
}

@test "Comp 3 files (dif 1 2)" {
	echo "test 1" > $test1
	echo "test 2" > $test2
	echo "test 2" > $test3
	comp $test1 $test2 $test3
	# sleep 2
	run bash -c "ps aux | grep vimdiff $test1 $test2 | grep -v grep"
	[ $status = 0 ]
	kill "$(echo "$output" | awk '{print $2}')"
}

@test "Comp 3 files (dif 2 3)" {
	echo "test 1" > $test1
	echo "test 1" > $test2
	echo "test 2" > $test3
	comp $test1 $test2 $test3
	# sleep 2
	run bash -c "ps aux | grep vimdiff $test1 $test3 | grep -v grep"
	[ $status = 0 ]
	kill "$(echo "$output" | awk '{print $2}')"
}

@test "Comp 3 different files" {
	echo "test 1" > $test1
	echo "test 2" > $test2
	echo "test 3" > $test3
	comp $test1 $test2 $test3
	# sleep 2
	run bash -c "ps aux | grep vimdiff $test1 $test2 $test3 | grep -v grep"
	[ $status = 0 ]
	kill "$(echo "$output" | awk '{print $2}')"
}

@test "Comp with a different viewer" {
	comp -m meld $test1 $test2
	# sleep 3
	run bash -c "ps aux | grep meld $test1 $test2 $test3 | grep -v grep"
	[ $status = 0 ]
	kill "$(echo "$output" | awk '{print $2}')"
}
