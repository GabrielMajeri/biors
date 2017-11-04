extern crate cc;

use std::path::Path;

fn main() {
    let arch_dir = Path::new("src/arch/x86");
    let start_asm = arch_dir.join("start.S");

    cc::Build::new()
        .warnings_into_errors(true)
        .file(start_asm)
        .compile("start");
}
