# biors
## The Basic Input / Output [Rust][rust] System
This repository contains an x86 platform firmware implementation - more commonly known as a [BIOS][BIOS].

It is written in Rust, and is designed for modern x86_64 processors.

Similarly to [CoreBoot][cboot], it is designed to deliver a "payload" -
this could be a PC-AT compatible BIOS, or a [UEFI][uefi] implementation.

[rust]: https://www.rust-lang.org
[bios]: https://en.wikipedia.org/wiki/BIOS
[cboot]: https://www.coreboot.org/
[uefi]: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface

## Build requirements
- [Make](https://www.gnu.org/software/make/)
- [Xargo](https://github.com/japaric/xargo/)
- C compiler (such as Clang or GCC) to assemble the `start.S` file.

## Pronounciation
BIOS is pronounced "**BY**-oss", this project is pronounced "**BY**-orss".
