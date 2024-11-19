.text
.global main
.extern printf

format_string:
    .string "sqrt(%2d) = %2d\n"

isqrt:
    xor %eax, %eax      # c = 0
    mov $1, %edx        # s = 1
    jmp .Lcheck

.Lloop:
    inc %eax            # c++
    lea (%edx,%eax,2), %edx
    inc %edx            # s += 2*c + 1

.Lcheck:
    cmp %edi, %edx      # compare s and n
    jle .Lloop          # if s <= n, continue loop

    ret                 # return c (in %eax)

main:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp       # Allocate stack space for n

    xor %ebx, %ebx      # n = 0

.Lfor_loop:
    cmp $20, %ebx
    jg .Lend_for

    mov %ebx, (%rsp)    # Store n on stack
    mov %ebx, %edi      # n as argument for isqrt
    call isqrt

    lea format_string(%rip), %rdi
    mov (%rsp), %esi    # n as first printf argument
    mov %eax, %edx      # isqrt(n) as second printf argument
    xor %eax, %eax      # Clear %eax for printf
    call printf

    inc %ebx            # n++
    jmp .Lfor_loop

.Lend_for:
    xor %eax, %eax      # Return 0
    leave
    ret