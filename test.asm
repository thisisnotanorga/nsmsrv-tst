%include "./macros/strutils.asm"
%include "./macros/sysutils.asm"
%include "./macros/httputils.asm"

section .data
    string db "SGVsbG8sIFdvcmxkICE=", 0
    request db "GET / HTTP/1.0", 0xd, 0xa, \
               "Authorization: Basic aGVsbG9oZWxsbzpteXBhc3M2NQ==", \
               0xd, 0xa, 0xd, 0xa

    request_len equ $ - request

section .bss
    output resb 258 ; 128 (user) + 1 (:) + 128 (pwd) + null term (1)

section .text
    global _start

_start:
    PARSE_AUTH_HEADER request, request_len, output, r10, 257
    PRINTN output, r10
    EXIT 0