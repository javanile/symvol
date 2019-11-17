#!/bin/bash
set -e
##
## SymVol v0.0.2
## -------------
## by Francesco Bianco
## info@javanile.org
## MIT License
##
SYMVOL_BIN=/usr/local/bin/symvol
SYMVOL_SRC=https://javanile.github.io/symvol/symvol.sh

echo "Get: ${SYMVOL_SRC} -> ${SYMVOL_BIN}"
curl --progress-bar -sLo ${SYMVOL_BIN} ${SYMVOL_SRC}

echo "Inf: apply executable permission to ${SYMVOL_BIN}"
chmod +x ${SYMVOL_BIN}

echo "Done."
