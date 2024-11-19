.data
.global m
.global memo

.text
.global main
.global f

# Function f
f:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15

    # Allocate registers for parameters and local variables
    # %rdi: i
    # %rsi: c
    mov %rdi, %r12  # i
    mov %rsi, %r13  # c
    
    # Compute key = c << 4 | i
    mov %r13, %r14
    shl $4, %r14
    or %r12, %r14   # %r14 now holds key

    # Check if memo[key] != 0
    lea memo(%rip), %r15
    mov (%r15,%r14,4), %eax
    test %eax, %eax
    jnz .L_return

    # If i == 15, return 0
    cmp $15, %r12
    je .L_return_zero

    # Initialize max = -1
    mov $-1, %ebx   # Use %ebx for max

    # Loop through j
    xor %rcx, %rcx  # j = 0
.L_loop:
    cmp $15, %rcx
    jge .L_end_loop

    # Check if bit j is set in c
    mov $1, %rax
    mov %cl, %cl    # Ensure shift amount is in %cl
    shl %cl, %rax
    test %rax, %r13
    jz .L_continue

    # Compute r = c & ~(1 << j)
    mov %r13, %r15
    not %rax
    and %r15, %rax  # %rax now holds r

    # Compute s = m[i][j] + f(i+1, r)
    lea m(%rip), %r15
    imul $60, %r12, %rdx
    add %rcx, %rdx
    mov (%r15,%rdx,4), %r15d  # %r15d now holds m[i][j]

    # Prepare parameters for recursive call
    lea 1(%r12), %rdi
    mov %rax, %rsi
    push %rcx
    call f
    pop %rcx
    add %r15d, %eax  # %eax now holds s

    # Update max if necessary
    cmp %ebx, %eax
    cmovg %eax, %ebx

.L_continue:
    inc %rcx
    jmp .L_loop

.L_end_loop:
    # Store result in memo[key]
    lea memo(%rip), %r15
    mov %ebx, (%r15,%r14,4)
    mov %ebx, %eax
    jmp .L_return

.L_return_zero:
    xor %eax, %eax

.L_return:
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# Main function
main:
    push %rbp
    mov %rsp, %rbp

    # Call f(0, 0x7FFF)
    xor %edi, %edi
    mov $0x7FFF, %esi
    call f

    # Print result
    mov %eax, %esi
    lea format_string(%rip), %rdi
    xor %eax, %eax
    call printf

    xor %eax, %eax
    pop %rbp
    ret

.data
format_string:
    .string "%d\n"