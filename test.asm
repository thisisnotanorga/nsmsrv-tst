%include "./macros/strutils.asm"
%include "./macros/sysutils.asm"
%include "./macros/httputils.asm"

section .data
    string db "SGVsbG8sIFdvcmxkICE=", 0
    request db "GET / HTTP/1.1", 0xd, 0xa, \
               "Host: localhost", 0xd, 0xa, \
               "User-Agent: curl/8.15.0", 0xd, 0xa, \
               "Authorization: Basic YWRtaW46YWRtaW4=", 0xd, 0xa, \
               0xd, 0xa

    request_len equ $ - request


section .bss
    output resb 258 ; 128 (user) + 1 (:) + 128 (pwd) + null term (1)

section .text
    global _start

_start:
    PARSE_AUTH_HEADER request, request_len, output, 258
    STRLEN output, rcx  ; null-term check
    PRINTN output, rcx
    EXIT 0