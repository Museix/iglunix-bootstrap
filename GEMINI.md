# Gemini Code Understanding

## Project Overview

This project, `iglunix-bootstrap`, is a set of shell scripts that build a complete LLVM/Musl-based toolchain and sysroot from a GNU/Linux host. It downloads and builds components like the Linux headers, musl libc, LLVM (Clang, LLD), libc++, libunwind, and even Rust. The goal is to create a self-contained development environment for a specific target architecture (e.g., x86_64, aarch64, riscv64).

The build process is orchestrated by the `boot.sh` script, which executes a series of numbered scripts in a specific order. Each numbered script is responsible for a specific part of the build process, such as fetching sources, building a component, or configuring the environment.

## Building and Running

### Building the Toolchain

To build the entire toolchain and sysroot, run the following command:

```sh
./boot.sh
```

This will download all the necessary sources and build them in the correct order. The resulting sysroot will be located in the `./sysroot` directory. The build process can be customized by setting environment variables before running `boot.sh`. The main configuration variables are set in `boot.sh` itself.

### Running the Toolchain

The project provides wrapper scripts to use the newly built toolchain. These scripts are named according to the target architecture, for example:

*   `x86_64-museix-linux-musl-cc.sh`
*   `x86_64-museix-linux-musl-c++.sh`

To compile a C++ file, you can use the following command:

```sh
./x86_64-museix-linux-musl-c++.sh sanity.cpp
```

This will compile `sanity.cpp` using the newly built Clang and other tools from the sysroot.

## Development Conventions

*   **Shell Scripting:** The entire build process is managed by shell scripts. The scripts are well-structured and modular.
*   **Build Order:** The build order is explicitly defined by the numbered scripts.
*   **Configuration:** The build is configured through environment variables set in the `boot.sh` script.
*   **Patching:** The project uses `patch` to apply custom modifications to the downloaded source code. The patch files are located in the root directory and in the `patches/` directory.
*   **Sanity Checks:** The `sanity.c` and `sanity.cpp` files serve as simple test cases to verify that the toolchain is working correctly.
