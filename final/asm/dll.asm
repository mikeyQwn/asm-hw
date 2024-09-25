format PE DLL
entry DllEntryPoint

include 'C:\FASM\INCLUDE\WIN32A.INC'

section '.data' data readable writeable

section '.code' code readable executable
proc DllEntryPoint hinstDLL, fdwReason, lpvReserved
    mov eax, 1
    ret
endp
proc sample args
    ret
endp

section '.edata' export data readable
    export 'dll.dll', \
           DllEntryPoint, 'DllEntryPoint', \
           sample, 'sample'

section '.idata' import data readable writeable

data fixups
end data
