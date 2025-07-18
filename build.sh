#!/bin/bash
set -xe

export GN_ARGS=$(cat args.gn | tr '\n' ' ' )

V8_FROM_SOURCE=1 cargo build -vv --release --target riscv64gc-unknown-linux-musl

mkdir -p librusty_v8

cp target/riscv64gc-unknown-linux-musl/release/gn_out/src_binding.rs librusty_v8/src_binding.rs
cp target/riscv64gc-unknown-linux-musl/release/gn_out/obj/librusty_v8.a librusty_v8/librusty_v8.a
cp target/riscv64gc-unknown-linux-musl/release/gn_out/args.gn librusty_v8/args.gn
tar -czf librusty_v8.tar.gz librusty_v8

