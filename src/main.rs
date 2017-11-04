#![feature(lang_items)]
#![no_std]
#![no_main]

extern crate x86;

mod no_std;

#[no_mangle]
pub extern fn rust_start(_bist: u32) {
    unsafe {
        x86::shared::io::outb(0x9E, b'!');
        x86::shared::io::outsb(0x9E, b"Hello world!");
    }

    loop {

    }
}
