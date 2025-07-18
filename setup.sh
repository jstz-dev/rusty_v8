#!/bin/bash
set -xe
git submodule update --init --recursive

python build/install-build-deps.py

# Required on linux (see https://github.com/jstz-dev/rusty_v8?tab=readme-ov-file#build-v8-from-source)
sudo apt install libglib2.0-dev

(cd build && git apply ../01_PATCH_RISCV_TOOLCHAIN.patch)
(cd v8 && git apply ../02_PATCH_V8_INTERNAL.patch)
