#!/bin/bash
set -e

cd $(dirname "$0")
trap "echo $0: Test fail." ERR
current=$(mktemp /tmp/symvol.test.XXXXXX)

../symvol.sh move fixtures volume

find . -name \* -print | sort - > ${current}
diff assert/move-test.txt ${current}

../symvol.sh move volume fixtures

find . -name \* -print | sort - > ${current}
diff assert/move-test.txt ${current}

echo "$0: Test success."
