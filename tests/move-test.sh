#!/bin/bash
set -e

cd $(dirname "$0")/assert
trap "echo $0: Test fail." ERR
current=$(mktemp /tmp/symvol.test.XXXXXX)

echo "---> Before testing"
find . -name \* -print | sort - > ${current}
diff assert.txt ${current}

echo "---> Assert #1"
../symvol.sh move fixtures volume
find . -name \* -print | sort - > ${current}
diff move-test.txt ${current}

echo "---> Assert #2"
../symvol.sh move volume fixtures
find . -name \* -print | sort - > ${current}
diff assert/move-test.txt ${current}

echo "$0: Test success."
