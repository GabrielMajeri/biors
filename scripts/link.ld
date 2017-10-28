/* Top of 32-bit address space. */
HIDDEN(top = 4096M);

/* Flash size. */
HIDDEN(size = 64K);
ASSERT(size >= 64K, "ROM size too small for QEMU");

/* Load point of the image. */
HIDDEN(base = top - size);

SECTIONS {
	. = base;

	.rodata : {
		*(.rodata*)
	}

	.text : {
		*(.text*)
	}

	. = top - 16;

	reset_vector : {
		*(reset_vector)
	}

	ASSERT(. == top, "Flash size is not right.")

	/DISCARD/ : {
		*(.eh_frame)
	}
}
