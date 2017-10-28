.code16

.rodata
early_gdt:
gdt_ptr:
	/* Null descriptor, used as pointer. */
	.short early_gdt.end - early_gdt
	.int early_gdt
	.short 0
early_gdt.data:

early_gdt.code:

early_gdt.end:

null_ivt:
	.short 0
	.int 0

.text
real_start:
	/* Disable maskable interrupts. */
	cli

	/* Save the Built-In Self Test's result. */
	mov %eax, %ebp

	/*
	After a RESET, the CPU's TLB might still have some pages cached.
	Invalidate them to prevent any issues.
	*/
	xor %eax, %eax
	mov %eax, %cr3

	/* Load a null IVT so the CPU will triple fault on any interrupt. */
	lidtl null_ivt

	jmp .

.section reset_vector, "ax"
.global _start
.type _start, function
_start:
	/* Manually encode jump instruction. */
	.byte 0xE9
	.int real_start - (. + 2)

.align 16
