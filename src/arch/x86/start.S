.code16

.rodata
/* Global descriptor table */
gdt:
/* Use null entry to store pointer to GDT. */
.global gdt_ptr
gdt_ptr:
	.word gdt_end - gdt - 1;
	.int gdt
	.align 8
gdt_code:
	.quad 0x00209A0000000000

gdt_data:
	.quad 0x0000920000000000

gdt_end:

.set CODE_SELECTOR, gdt_code - gdt
.set DATA_SELECTOR, gdt_data - gdt

.global null_ivt_ptr
null_ivt_ptr:
	.word 0
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

	/*
	Code segment's base on startup is 0xFFFF_0000.
	We can use that to access our data structures.
	*/
	mov %cs, %ax
	shl $4, %ax

	/* Load a null IVT so the CPU will triple fault on any interrupt. */
	mov $null_ivt_ptr_offset, %bx
	sub %ax, %bx

	lidtl %cs:(%bx)

	/* Load a 64-bit GDT. */
	mov $gdt_ptr_offset, %bx
	sub %ax, %bx

	lgdtl %cs:(%bx)

	/* Need to set some CR4 flags for long-mode. */
	mov %cr4, %eax

	/*
	Long mode uses the same structures as Physical-Address Extensions,
	therefore it must be enabled.
	*/
	or $(1 << 5), %eax

	mov %eax, %cr4

	/* Enable some features in the EFER MSR. */
	mov $0xC0000080, %ecx
	rdmsr

	/* Enable long mode. */
	or $(1 << 8), %eax

	wrmsr

	/* CR3 must point to the top-level page mapping table. */
	mov $pml4, %eax
	mov %eax, %cr3

	/* Set up some CR0 flags. */
	mov %cr0, %eax

	/* Enable protected mode, cache disable and paging. */
	or $((1 << 0) | (1 << 30) | (1 << 31)), %eax

	mov %eax, %cr0

	/* Force the CPU to reload CS, to enter long mode. */
	ljmpl $CODE_SELECTOR, $long_mode_start

.section reset_vector, "ax"
.global _start
.type _start, function
_start:
	/* Manually encode jump instruction. */
	.byte 0xE9
	.int real_start - (. + 2)

.align 16
.previous

.code64
long_mode_start:
	/* Load the various segments with the 64-bit data segment. */
	mov $DATA_SELECTOR, %ax

	mov %ax, %ds
	mov %ax, %ss
	mov %ax, %es

	/* Restore BIST value. */
	mov %ebp, %edx

	/* Set up a stack. */
	mov $0x10000, %esp

	/* Create a new stack frame. */
	mov $., %ebp

	call rust_start

hang:
	hlt
	jmp hang
