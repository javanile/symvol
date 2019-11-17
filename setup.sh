#!/bin/bash
set -e

SYMVOL_BIN=/usr/local/bin/symvol
SYMVOL_SRC=https://javanile.github.io/symvol/symvol.sh

echo "Get: ${SYMVOL_SRC} -> ${SYMVOL_BIN}"
curl --progress-bar -sLo ${SYMVOL_BIN} ${SYMVOL_SRC}

echo "Inf: apply executable permission to ${SYMVOL_BIN}"
chmod +x ${SYMVOL_BIN}

echo "Done."
