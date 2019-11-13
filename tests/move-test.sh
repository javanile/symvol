#!/bin/bash
set -e

cd $(dirname "$0")/assert
trap "echo $0: Test fail." ERR
current=$(mktemp /tmp/symvol.test.XXXXXX)

assert () {
    echo "---"
    find * -print | sort - > ${current}
    diff ../$1.txt ${current}
}

echo "---> Before test"
rm -fr source target volume
mkdir -p source target volume
cp -rf ../fixtures/. source
assert before

echo "---> Assert #1"
../../symvol.sh move source target
assert move-test-assert-1

echo "---> Assert #2"
../../symvol.sh move target source
assert move-test-assert-2

echo "$0: Test success."
