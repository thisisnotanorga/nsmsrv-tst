; strutils.asm - String utility macros for x86_64 Linux

; STRLEN string_ptr, out_reg
;   Calculates the length of a null-terminated string.
;   Args:
;     %1: pointer to string
;     %2: register to store length
;   Clobbers: rax, rbx
%macro STRLEN 2
    push rax
    push rbx

    mov %2, 0
%%loop:
    mov bl, [%1 + %2]
    cmp bl, 0
    je %%done
    inc %2
    jmp %%loop

%%done:
    pop rbx
    pop rax
%endmacro

; STRCUT buf, char
;   Truncates a null-terminated string at the first occurrence of char.
;   If char is not found, the string is left untouched.
;   Args:
;     %1: pointer to the null-terminated buffer
;     %2: byte value to cut at (e.g. '!', 0xa)
;   Clobbers: rax, rbx
%macro STRCUT 2
    push rax
    push rbx

    lea rax, [%1]      ; rax = walking pointer

%%loop:
    mov bl, [rax]      ; load current byte

    cmp bl, 0
    je %%done          ; hit NUL, char not found

    cmp bl, %2
    je %%cut           ; found the target char

    inc rax            ; advance pointer
    jmp %%loop

%%cut:
    mov byte [rax], 0  ; overwrite char with NUL, truncating here

%%done:
    pop rbx
    pop rax
%endmacro

; STREQ a, b, out_reg
;   Compares two null-terminated strings.
;   Args:
;     %1: pointer to string a
;     %2: pointer to string b
;     %3: register to store result (1 if equal, 0 otherwise)
;   Clobbers: rax, rbx, rsi, rdi
%macro STREQ 3
    push rsi
    push rdi

    mov rsi, [%1]
    lea rdi, [%2]

%%loop:
    mov al, [rsi]
    mov bl, [rdi]

    cmp al, bl
    jne %%not_equal

    test al, al
    jz %%equal

    inc rsi
    inc rdi
    jmp %%loop

%%equal:
    mov %3, 1
    jmp %%done

%%not_equal:
    xor %3, %3

%%done:
    pop rdi
    pop rsi
%endmacro

; APPEND dest, src, length
;   Copies `length` bytes from src into dest, advancing dest.
;   Args:
;     %1: destination pointer (incremented in place)
;     %2: source buffer address
;     %3: number of bytes to copy
;   Notes:
;     Does not null-terminate the destination.
;   Clobbers: rax, rsi, rcx
%macro APPEND 3
    mov rsi, %2
    mov rcx, %3

%%loop:
    cmp rcx, 0
    je %%done

    mov al, [rsi]
    mov [%1], al

    inc rsi
    inc %1

    dec rcx
    jmp %%loop

%%done:
%endmacro

; AAPPEND dest, src
;   Appends a null-terminated string to dest, advancing dest.
;   Args:
;     %1: destination pointer (incremented in place)
;     %2: source string (null-terminated)
;   Notes:
;     Does not null-terminate the destination.
;   Clobbers: rax, rbx, rsi, rcx
%macro AAPPEND 2
    STRLEN %2, rcx  ; length -> rcx
    mov rsi, %2

%%loop:
    cmp rcx, 0
    je %%done

    mov al, [rsi]
    mov [%1], al

    inc rsi
    inc %1

    dec rcx
    jmp %%loop

%%done:
%endmacro

; BUILDPATH dest, base, suffix
;   Concatenates base and suffix into dest (null-terminated result).
;   If the base OR suffix string is empty, it'll leave the buffer untouched.
;   Args:
;     %1: destination buffer
;     %2: base string (null-terminated)
;     %3: suffix string (null-terminated)
;   Clobbers: whatever AAPPEND clobbers (rax, rbx, rsi, rcx)
%macro BUILDPATH 3

    ; if either part is empty, leave dest empty and bail
    cmp byte [%2], 0
    je %%done
    cmp byte [%3], 0
    je %%done

    lea r8, [%1]
    AAPPEND r8, %2
    AAPPEND r8, %3
    mov byte [r8], 0  ; null-terminate

%%done:
%endmacro