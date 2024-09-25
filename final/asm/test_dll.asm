format PE console
entry start

include 'C:\FASM\INCLUDE\WIN32A.INC'

section '.data' data readable writeable
    dll_name db 'dll.dll', 0
    func_name db 'sample', 0
    hLib dd 0
    sample dd 0

section '.code' code readable executable
start:
    invoke LoadLibrary, dll_name
    mov [hLib], eax
    test eax, eax
    jz exit_program

    invoke GetProcAddress, [hLib], func_name
    mov [spliceLeft], eax
    test eax, eax
    jz free_library

    push ...
    call [sample]

free_library:
    invoke FreeLibrary, [hLib]

exit_program:
    invoke ExitProcess, 0

section '.idata' import data readable writeable
    library kernel, 'kernel32.dll'
    import kernel, \
           LoadLibrary, 'LoadLibraryA', \
           FreeLibrary, 'FreeLibrary', \
           GetProcAddress, 'GetProcAddress', \
           ExitProcess, 'ExitProcess'
