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

	gdt_ptr_offset = gdt_ptr & 0xFFFF;
	null_ivt_ptr_offset = null_ivt_ptr & 0xFFFF;

	/* Build a paging structure. */
	.rodata.pm : {
		/* Flags used for paging structures. */
		HIDDEN(PAGE_PRESENT = 1 << 0);
		HIDDEN(PAGE_WRITABLE = 1 << 1);
		HIDDEN(PAGE_SIZE = 1 << 7);

		/* Top-level page mapping structure. Each entry manages 512 GiB. */
		. = ALIGN(4K);
		pml4 = .;
			/* PDP for first 512 GiB. */
			QUAD(pdp | PAGE_PRESENT | PAGE_WRITABLE);

		/* The PDP's entries each manage a 1 GiB area. */
		. = ALIGN(4K);
		HIDDEN(pdp = .);
			HIDDEN(page_flags = PAGE_PRESENT | PAGE_WRITABLE | PAGE_SIZE);
			QUAD(0 | page_flags);
			QUAD(1024M | page_flags);
			QUAD(2048M | page_flags);
			QUAD(3072M | page_flags);
	} = 0

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
		*(.comment*)
		*(.note*)
	}
}
