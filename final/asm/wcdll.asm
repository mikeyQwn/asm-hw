format PE console DLL
entry DllEntryPoint

include 'C:\fasm\INCLUDE\win32a.inc'

section '.data' readable writeable
    out_buf_size dd 0
    max_iter dd 0
	current_position dd 0

	first dw 0
	second dw 0
	third dw 0

	first_cmp dw 0
	second_cmp dw 0
	third_cmp dw 0

	current_type dd 0

	lookup db 2, 2, 2, 4, 4, 4,  9,  8, 10, 5, 5, 5, 3, 3, 3, 6, 6, 6, 12, 11, 13, 7, 7,  7, 1, 1, 1

	print_fmt db 'Idx: %d, Ty: %d, f: %d, s: %d, t: %d', 0xA, 0

section '.text' code readable executable

proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
	mov	eax, 1
	ret
endp

; eax - a, ebx - b, ecx - c
get_type:
	movzx eax, al
	lea eax, [eax * 8 + eax]

	movzx ebx, bl
	lea ebx, [ebx * 2 + ebx]

	movzx ecx, cl

	add eax, ebx
	add eax, ecx

	movzx eax, byte [lookup + eax]
	ret

; eax - a, ebx - b
get_cmp:
	movzx eax, ax
	movzx ebx, bx

	cmp eax, ebx
    jb  less
    je  equal   

	mov eax, 2
	ret

less:
	xor eax, eax
	ret

equal:
	mov al, 1
	ret


proc Wc in_buf, buf_size, out_buf
    mov eax, [buf_size]
    mov [out_buf_size], eax 
    shr [out_buf_size], 3

    mov eax, [buf_size]
	mov [max_iter], eax 
	sub [max_iter], 8

	xor ecx, ecx
	mov [current_position], ecx

mainloop:
	mov ebx, [in_buf]
	; Первое число
	mov [first], 0
	movzx eax, byte[ebx + ecx + 2]
	mov [first], ax
	movzx eax, byte[ebx + ecx + 3]
	add [first], ax

	; Второе число
	mov [second], 0
	movzx eax, byte[ebx + ecx + 6]
	mov [second], ax
	movzx eax, byte[ebx + ecx + 7]
	add [second], ax

	; Третье число
	mov [third], 0
	movzx eax, byte[ebx + ecx + 10]
	mov [third], ax
	movzx eax, byte[ebx + ecx + 11]
	add [third], ax

	push ecx

	movzx eax, [first]
	movzx ebx, [second]
	call get_cmp
	mov [first_cmp], ax

	movzx eax, [second]
	movzx ebx, [third]
	call get_cmp
	mov [second_cmp], ax

	movzx eax, [third]
	movzx ebx, [first]
	call get_cmp
	mov [third_cmp], ax

	movzx eax, [first_cmp]
	movzx ebx, [second_cmp]
	movzx ecx, [third_cmp]

	call get_type
	mov [current_type], eax
	mov ebx, [out_buf]
	mov ecx, [current_position]
	mov byte [ebx+ecx], al

	add [current_position], 1

	;push eax
	;push ebx
	;push ecx
	;push edx
	;
	;movzx ebx, [first_cmp]
	;movzx ecx, [second_cmp]
	;movzx edx, [third_cmp]
	;
	;invoke printf, print_fmt, [current_position], [current_type], ebx, ecx, edx
	;add esp, 24
	;
	;pop edx
	;pop ecx
	;pop ebx
	;pop eax

	pop ecx

	add ecx, 8

	cmp ecx, [max_iter]
	jl mainloop

    mov eax, [current_position]
	ret
endp

section '.idata' import data readable writeable
  library kernel, 'kernel32.dll', \
	  user, 'user32.dll', \
	  msvcrt, 'msvcrt.dll'

section '.edata' export data readable
  export 'wcdll.dll', \
	 Wc, 'Wc'

import msvcrt, \
    printf, 'printf'

section '.reloc' fixups data readable discardable
  if $=$$
    dd 0,8
  end if
