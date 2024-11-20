	.text
	.globl	main
main:
print_int:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rdi
	movq %rax, %rsi
	movq $format_int, %rdi
	movq $0, %rax
	call printf
	popq %rdi
	popq %rbp
	ret
	ret
	.data
format_int:
	.string "%d\n"
format_str:
	.string "%s\n"
