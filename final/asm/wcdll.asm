format PE console DLL
entry DllEntryPoint

include 'C:\fasm\INCLUDE\win32a.inc'

section '.data' readable writeable
    out_buf_size dd 0

section '.text' code readable executable

proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
	mov	eax, 1
	ret
endp

proc Wc in_buf, buf_size, out_buf
    mov eax, [buf_size]
    mov [out_buf_size], eax 
    shr [out_buf_size], 3

    mov eax, dword [out_buf_size]
	ret
endp

section '.idata' import data readable writeable
  library kernel, 'kernel32.dll', \
	  user, 'user32.dll'

section '.edata' export data readable
  export 'wcdll.dll', \
	 Wc, 'Wc'

section '.reloc' fixups data readable discardable
  if $=$$
    dd 0,8
  end if
