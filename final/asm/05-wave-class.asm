; Задача - классифицировать количество замеров по трем точкам

format PE console

entry start
include 'C:\fasm\INCLUDE\win32a.inc'

section '.data' readable writeable
        filename db 'input.bin', 0
        out_filename db 'output.bin', 0
        failed_to_open_file_msg db 'Failed to open the file! Error code: %d', 0xA, 0x0
        failed_to_allocate_memory_msg db 'Failed to allocate memory for the file content buffer', 0xA, 0x0
        file_size_fmt db 'File size: %d bytes', 0xA, 0x0
        failed_to_read_file_msg db 'Failed to oread the file to a buffer', 0xA, 0x0
        byte_fmt db '%d', 0
		index_value_fmt db '%d: %d', 0xA, 0

section '.bss' readable writeable
        h_file dd ?
        h_out_file dd ?
        file_size dd ?
        file_buffer dd ?
        out_buffer dd ?
        out_buffer_len dd ?
        bytes_read dd ?


section '.code' code readable executable
start:
    ; Открытие файла с входными значениями с именем `input.bin`, сохранение handle
    invoke CreateFileA, filename, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
        mov [h_file], eax

        cmp [h_file], INVALID_HANDLE_VALUE 
        je file_error

    ; Получение размера файла 
    invoke GetFileSize, [h_file], 0
        mov [file_size], eax

    ; Выделение памяти для массива, в который запишутся байты файла
    invoke VirtualAlloc, 0, [file_size], MEM_COMMIT, PAGE_READWRITE
        mov [file_buffer], eax

        mov eax, [file_size]
        shr eax, 3
        mov [out_buffer_len], eax

    ; Выделение памяти для массива, в который запишутся байты выходного файла
    invoke VirtualAlloc, 0, eax, MEM_COMMIT, PAGE_READWRITE
        mov [out_buffer], eax

        cmp eax, 0
    je mem_error

    ; Чтение файла с входными значениями
    invoke ReadFile, [h_file], [file_buffer], [file_size], bytes_read, 0
        cmp eax, 0
    je read_error

    ; Распечатывание размера входного файла в байтах
    invoke printf, file_size_fmt, [file_size]

    ; Зактыие handle входного файла 
    invoke CloseHandle, [h_file]

    ; Общащение к dll
    invoke Wc, [file_buffer], [file_size], [out_buffer]

    ; Распечатка выходного массива
        mov ecx, [out_buffer_len]
		xor ebx, ebx
print_loop:
        mov eax, [out_buffer]
		movzx eax, byte[eax + ebx]
		push ecx

    invoke printf, index_value_fmt, ebx, eax
		add esp, 12

		pop ecx
		inc ebx


		cmp ebx, ecx
    jl print_loop

    ; Создание выходного файла с именем `output.bin`
    invoke CreateFileA, out_filename, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
        mov [h_out_file], eax
        cmp [h_out_file], INVALID_HANDLE_VALUE 
    je file_error

    ; Запись выходного массива в файл
    invoke WriteFile, [h_out_file], [out_buffer], [out_buffer_len], 0, 0

    ; Закрытие выходного файла
    invoke CloseHandle, [h_out_file]

exit:
    invoke ExitProcess, 0

file_error:
    invoke GetLastError
    invoke printf, failed_to_open_file_msg, eax
    invoke ExitProcess, 1

mem_error:
    invoke printf, failed_to_allocate_memory_msg
    invoke ExitProcess, 1

read_error:
    invoke printf, failed_to_read_file_msg
    invoke ExitProcess, 1


section '.idata' import data readable writeable
library kernel32, 'kernel32.dll', \
        msvcrt, 'msvcrt.dll', \
        wcdll, 'wcdll.dll'

import kernel32, \
    CreateFileA, 'CreateFileA', \
    GetFileSize, 'GetFileSize', \
    CloseHandle, 'CloseHandle', \
    ReadFile, 'ReadFile', \
    VirtualAlloc, 'VirtualAlloc', \
    LoadLibrary, 'LoadLibraryA', \
    FreeLibrary, 'FreeLibrary', \
    GetProcAddress, 'GetProcAddress', \
    GetLastError, 'GetLastError', \
    WriteFile, 'WriteFile', \
    ExitProcess, 'ExitProcess'

import msvcrt, \
    printf, 'printf'

import wcdll, \
	Wc,'Wc'
