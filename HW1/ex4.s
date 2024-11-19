.data
x: .long 2
y: .long 0

.text
.global main
.extern printf

format_string:
    .string "%d\n"

main:
    push %rbp
    mov %rsp, %rbp

    # let x = 2 (already set in the data segment)

    # let y = x * x
    mov x(%rip), %eax
    imul %eax, %eax
    mov %eax, y(%rip)

    # print (y + x)
    mov y(%rip), %eax
    add x(%rip), %eax
    
    lea format_string(%rip), %rdi  # Load address of format_string into %rdi
    mov %eax, %esi                 # Move the result into %esi
    xor %eax, %eax                 # Clear %eax (set to zero)
    call printf                    # Call printf

    mov $0, %rax                   # syscall: exit
    pop %rbp                       # status: 0
    ret