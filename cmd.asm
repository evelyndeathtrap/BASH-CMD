; full code compressed

section .data
    space db ' '
    newline db 10

section .text
    global _start

_start:
    pop rbx                 ; argc (first thing on stack)
    pop rax                 ; argv[0] (skip program name)
    dec rbx                 ; Adjust argc to count remaining args
    jz exit                 ; If no args, exit

    ; We will use r12 as our "current position" in a stack-allocated buffer
    ; For simplicity in this example, we'll use a fixed-size buffer on the stack.
    ; In a real 'malloc' equivalent, you'd use the 'brk' or 'mmap' syscalls.
    sub rsp, 4096           ; Allocate 4KB on stack
    mov r12, rsp            ; r12 points to the start of our buffer

.loop_args:
    pop rsi                 ; Get next argv string pointer
    test rsi, rsi           ; Check if null
    jz .done

.copy_str:
    mov al, [rsi]           ; Load byte from source
    test al, al             ; Check for null terminator
    jz .next_arg
    mov [r12], al           ; Store byte in buffer
    inc rsi
    inc r12
    jmp .copy_str

.next_arg:
    dec rbx                 ; Decrease count of remaining args
    jz .done                ; If last arg, don't add space
    mov byte [r12], ' '     ; Add space separator
    inc r12
    jmp .loop_args

.done:
    mov byte [r12], 10      ; Add newline at the end
    inc r12

    ; Calculate final length: current_pos - start_pos
    mov rdx, r12
    sub rdx, rsp            ; rdx = length

    ; syscall: write(1, buffer, length)
    mov rax, 1              ; sys_write
    mov rdi, 1              ; fd 1 (stdout)
    mov rsi, rsp            ; buffer
    syscall

exit:
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; exit code 0
    syscall
