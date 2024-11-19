  .text                   # instructions follow
  .globl main             # make main visible for ld
main:
  pushq %rbp
  movq %rsp, %rbp
  leaq message(%rip), %rdi  # load address of message into %rdi (first argument for puts)
  call puts
  movq $0, %rax
  popq %rbp
  ret
  .data                   # data follow
message:  
  .string "hello, world"  # 0-terminated string