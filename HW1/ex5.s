.text
.global main
.extern printf

format_string:
    .string "%d\n"

main:
    push %rbp                      # Set up stack frame
    mov %rsp, %rbp

    # First expression: let x = 3 in x * x
    # x = 3
    mov $3, %eax                    # Move 3 into %eax (x)
    imul %eax, %eax                 # x * x (i.e., 3 * 3 = 9)
    
    # Print result (9)
    lea format_string(%rip), %rdi   # Load address of format_string into %rdi
    mov %eax, %esi                  # Move result (9) into %esi
    xor %rax, %rax                  # Clear %rax for printf call
    call printf                     # Call printf to print the first result

    # Second expression: let x = 3 in (let y = x + x in x * y) + (let z = x + 3 in z / z)
    # x = 3
    mov $3, %eax                    # Move 3 into %eax (x)

    # Inner expression: let y = x + x in x * y
    mov %eax, %edx                  # Move x (3) into %edx (temporary storage for y)
    add %eax, %edx                  # y = x + x (3 + 3 = 6)
    imul %eax, %edx                 # x * y (3 * 6 = 18)
    
    # Store the result of x * y in %edx for later use
    mov %edx, %ebx                  # Store 18 in %ebx (to save x * y)

    # Second inner expression: let z = x + 3 in z / z
    mov %eax, %eax                  # Move x (3) into %eax
    add $3, %eax                    # z = x + 3 (3 + 3 = 6)
    mov %eax, %ecx                  # Copy z into %ecx for division
    mov %ecx, %eax                  # z / z (6 / 6)
    xor %edx, %edx                  # Clear %edx before division (to store remainder)
    div %ecx                        # Perform division: z / z (6 / 6 = 1)
    
    # Add the two results: (x * y) + (z / z)
    add %ebx, %eax                  # 18 + 1 = 19

    # Print result (19)
    lea format_string(%rip), %rdi   # Load address of format_string into %rdi
    mov %eax, %esi                  # Move result (19) into %esi
    xor %rax, %rax                  # Clear %rax for printf call
    call printf                     # Call printf to print the second result

    # Exit
    mov $0, %rax                    # syscall: exit
    pop %rbp                        # Restore previous base pointer
    ret
