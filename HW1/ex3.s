.data
msg_true:
    .string "true\n"
msg_false:
    .string "false\n"
msg_expression2:
    .string "%d\n"

.text
.global main
.extern printf

print_bool:
    push %rbp
    mov %rsp, %rbp
    
    test %rdi, %rdi             # 若rdi=0 => ZF(zero flag)=1
    /* rdi =  0 (false) */
    jz print_false              # jump if zero(ZF)
    /* rdi = 1 (true) */
    lea msg_true(%rip), %rdi    # 上面沒jump就把rdi設為msg_true的位址
    jmp print                   # 上面已經記msg_true的位址了
    
print_false:
    lea msg_false(%rip), %rdi   # 把rdi設為msg_false的位址
    
print:
    xor %rax, %rax
    call printf
    leave
    ret

main:
    push %rbp
    mov %rsp, %rbp
    
    # Evaluate true && false
    mov $1, %rdi    # true
    and $0, %rdi    # false
    call print_bool

    # if 3 <> 4 then 10 * 2 else 14
    mov $3, %rax
    cmp $4, %rax
    je else_clause
    mov $20, %rsi   # 10 * 2
    jmp print_result

    # 2 = 3 || 4 <= 2 * 3
    mov $0, %rdi    # Initialize result to false
    mov $2, %rax
    cmp $3, %rax
    je true_result
    mov $4, %rax
    cmp $6, %rax    # 2 * 3 = 6
    jle true_result
    jmp print_bool_result

else_clause:
    mov $14, %rsi

print_result:
    lea msg_expression2(%rip), %rdi
    xor %rax, %rax
    call printf

true_result:
    mov $1, %rdi
print_bool_result:
    call print_bool

xor %rax, %rax  # Return 0
leave
ret