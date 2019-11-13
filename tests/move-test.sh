#!/bin/bash
set -e

cd $(dirname "$0")/assert
trap "echo $0: Test fail." ERR
current=$(mktemp /tmp/symvol.test.XXXXXX)

assert () {
    find * -print | sort - > ${current}
    diff ../$1.txt ${current}
}

echo "---> Before test"
mkdir -p source target volume
cp -rf ../fixtures/. source
assert before

echo "---> Assert #1"
../../symvol.sh move source target
assert move-test-assert

echo "---> Assert #2"
../../symvol.sh move target source
assert before

echo "---> After test"
rm -fr source/* target/* volume/*
assert after

echo "$0: Test success."
