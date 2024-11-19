.text
.global main
.extern printf

format_string:
    .string "n = %d\n"

main:
    push %rbp
    mov %rsp, %rbp
    lea format_string(%rip), %rdi  # Load address of format_string into %rdi
    mov $42, %rsi                  # Move the integer 42 into %rsi
    xor %rax, %rax                 # Clear %rax (set to zero)
    call printf                    # Call printf

    mov $0, %rax                  # syscall: exit
    pop %rbp                      # status: 0
    ret    