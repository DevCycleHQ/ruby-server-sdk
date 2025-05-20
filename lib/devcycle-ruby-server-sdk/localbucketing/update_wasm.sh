#!/bin/bash
BUCKETING_LIB_VERSION="1.35.1"
WAT_DOWNLOAD=0
rm bucketing-lib.release.wasm
wget "https://unpkg.com/@devcycle/bucketing-assembly-script@$BUCKETING_LIB_VERSION/build/bucketing-lib.release.wasm"