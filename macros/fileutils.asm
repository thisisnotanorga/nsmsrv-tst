; fileutils.asm - File operation macros for x86_64 Linux

section .bss
    stat resb 144   ; struct stat is 144 bytes on x86_64 linux (for content length)


; FILE_EXISTS path
;   Checks whether a file exists on disk.
;   Args:
;     %1: null-terminated path
;   Returns:
;     rax = 1 if exists, 0 otherwise
;   Clobbers: rax, rdi, rsi
%macro FILE_EXISTS 1
    mov rax, 21     ; sys_access
    mov rdi, %1
    mov rsi, 0      ; F_OK
    syscall

    cmp rax, 0
    je %%exists

    mov rax, 0
    jmp %%done

%%exists:
    mov rax, 1

%%done:
%endmacro

; FILE_SIZE path, out_reg
;   Gets the size of a file in bytes.
;   Args:
;     %1: null-terminated path
;     %2: register to store the size (-1 on error)
;   Clobbers: rax, rdi, rsi
%macro FILE_SIZE 2
    push rdi
    push rsi

    ; stat(path, buffer)
    mov rax, 4
    mov rdi, %1
    lea rsi, [stat]
    syscall

    cmp rax, 0
    jl %%fail

    mov %2, [stat + 48] ; st_size is at offset 48 in struct stat
    jmp %%done

%%fail:
    mov %2, -1

%%done:
    pop rsi
    pop rdi
%endmacro

; READ_FILE fd, buffer, length
;   Reads up to `length` bytes from a file descriptor into a buffer.
;   Args:
;     %1: file descriptor
;     %2: buffer address
;     %3: buffer size
;   Returns:
;     rax = bytes read, or negative errno on error
;   Clobbers: rax, rdi, rsi, rdx
%macro READ_FILE 3
    mov rax, 0      ; sys_read
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

; OPEN_FILE path
;   Opens a file for reading.
;   Args:
;     %1: null-terminated path
;   Returns:
;     rax = file descriptor, or negative errno on error
;   Clobbers: rax, rdi, rsi, rdx
%macro OPEN_FILE 1
    mov rax, 2      ; sys_open
    mov rdi, %1
    mov rsi, 0      ; O_RDONLY
    mov rdx, 0
    syscall
%endmacro