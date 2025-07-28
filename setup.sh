#!/bin/bash
set -xe

if [ ! -d "riscv64-linux-musl-cross" ]; then
	curl -O -L https://musl.cc/riscv64-linux-musl-cross.tgz
	tar -xzf riscv64-linux-musl-cross.tgz
	rm riscv64-linux-musl-cross.tgz 
fi

git submodule update --init --recursive

python build/install-build-deps.py

# Required on linux (see https://github.com/jstz-dev/rusty_v8?tab=readme-ov-file#build-v8-from-source)
sudo apt install libglib2.0-dev

set +e

(cd build && git apply ../0001_BUILD_PATCH_RISCV_TOOLCHAIN.patch)

# Apply v8 patches
v8_patches=(
	"0002_V8_PATCH_INTERNAL.patch"
	"0003_V8_DO_NOT_FORCE_ENABLE_PTR_CMPRSN.patch"
	"0004_V8_SWITCH_OFF_LARGER_CAGED_HEAPS.patch"
)
cd v8
for patch in "${v8_patches[@]}"; do
	git apply "../$patch"
done
cd ..
