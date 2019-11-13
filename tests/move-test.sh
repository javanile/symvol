#!/bin/bash
set -e

testdir=$(dirname "$0")/assert
current=$(mktemp /tmp/symvol.test.XXXXXX)

mkdir -p ${testdir}
cd ${testdir}

trap "echo $0: Test fail." ERR

assert () {
    echo "---"
    find * -printf "%y %p\\n" | sort - > ${current}
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
