%include "./macros/strutils.asm"
%include "./macros/sysutils.asm"

section .data
    string db "SGVsbG8sIFdvcmxkICE=", 0

section .bss
    output resb 128

section .text
    global _start

_start:
    B64_DECODE string, output, rcx

    PRINTN output, rcx
    EXIT 0