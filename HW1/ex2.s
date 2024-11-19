    .text
    .globl main
    .extern printf

main:
    push %rbp
    mov %rsp, %rbp

    /* 4 + 6 */
    lea format_string(%rip), %rdi

    mov $4, %eax    # eax:放加法的結果
    add $6, %eax

    mov %eax, %esi  # esi: source index，指向來源index
    xor %eax, %eax  # 清空 eax
    call printf

    /* 21 * 2 */
    lea format_string(%rip), %rdi

    mov $21, %eax
    imul $2, %eax

    mov %eax, %esi
    xor %eax, %eax
    call printf

    /* 4 + 7 / 2 */
    lea format_string(%rip), %rdi

    mov $7, %eax
    xor %edx, %edx  # 清空 edx
    mov $2, %ecx
    div %ecx        # 7/2，結果放 eax
    add $4, %eax

    mov %eax, %esi
    xor %eax, %eax
    call printf

    /* 3 - 6 * (10 / 5) */
    lea format_string(%rip), %rdi

    mov $10, %eax   # eax = 10
    xor %edx, %edx  # 清空 edx
    mov $5, %ecx    # ecx = 5
    div %ecx        # eax = 10/5
    mov $6, %ebx    # ebx = 6
    imul %eax, %ebx # ebx = eax*ebx -> ebx = 6*(10/5)
    mov $3, %eax    # eax = 3
    sub %ebx, %eax  # eax = eax-ebx -> eax = 3-[6*(10/5)]

    mov %eax, %esi
    xor %eax, %eax
    call printf

    /* return 0 */
    mov $0, %eax
    pop %rbp
    ret

    .data
format_string:
    .string "%d\n"