#!/bin/sh -e
[ -f "$REPO_ROOT/.tblgen" ] && exit 0

cd "$BUILD"
mkdir -p tblgen
cd tblgen

cmake -G Ninja "$SOURCES/llvm-$LLVM_VER/llvm" \
-DLLVM_ENABLE_PROJECTS=all \
-DLLVM_ENABLE_RUNTIMES=all \
-DCMAKE_C_COMPILER=cc \
-DCMAKE_CXX_COMPILER=c++ \
-DCMAKE_BUILD_TYPE=Release

samu llvm-tblgen clang-tblgen llvm-min-tblgen

touch $REPO_ROOT/.tblgen
