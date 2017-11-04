// extern crate rlibc;
// extern crate compiler_intrinsics;

#[lang = "eh_personality"]
extern fn eh_personality() {}

#[lang = "panic_fmt"]
#[allow(private_no_mangle_fns)]
#[no_mangle]
extern fn panic_fmt() -> ! {
    loop {}
}
