; Поиск порядка разницы 
;
; Назначение программы: поиск порядка разницы 
; двух соседних значений в массиве чисел

format PE Console

entry start
include 'C:\FASM\INCLUDE\win32a.inc'

section '.data' data readable writeable
    stdin               dd     0
    stdout              dd     0
    in_msg              db     'Input your number sequence: '
    in_msg_len          =      $ - in_msg
    number_display_fmt  db     '%d: %d', 0xA, 0
    total_length_fmt    db     'Numbers in total: %d', 0xA, 0
    diff_fmt            db     'log2(diff): %d', 0xA, 0
    mask                dd     2147483648  ; 0b10000000000000000000000000000000
                                           ; Маска для получения первого бита 32-х битного числа
    buffer              db     1024 dup 0
    number_index        dd     0x0 ; Индекс обрабытываемого числа

section '.code' code readable executable
start:
    invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov [stdout], eax
    invoke GetStdHandle,STD_INPUT_HANDLE
        mov [stdin], eax

    invoke WriteFile, [stdout], in_msg, in_msg_len, 0, 0
    invoke ReadFile, [stdin], buffer, 1023, 0, 0

        mov ebx, 1
        xor esi, esi ; Смещение с начала читаемой строки
parse_ints:
    call atoi
        push eax

    invoke printf, number_display_fmt, [number_index], eax
        add esp, 12

        inc [number_index]
        inc esi

        cmp [number_index], 2
    jl skip_displaying

        pop ecx
        pop eax
        push ecx

    call abs_diff
        push ebx
    call log2
        pop ebx
    invoke printf, diff_fmt, eax
        add esp, 8

skip_displaying:
        cmp ebx, 0
    jne parse_ints

    invoke printf, total_length_fmt, [number_index]
        add esp, 8

    invoke getch

    invoke ExitProcess, 0

; ------------------------- ;

; esi[in] - size_t offset
; 
; esi[out] - size_t new_offset
; ebx[out] - int is_over
atoi:
        xor eax, eax
        mov ecx, 10

atoi_loopstart:
        cmp byte[buffer+esi], ' '
    je atoi_end

        cmp byte[buffer+esi+2], 0
    je atoi_final

        mov ecx, 10
        mul ecx 
        mov bl, byte[buffer+esi]
        sub bl, 48
        add al, bl

        inc esi
    jmp atoi_loopstart

atoi_final:
        xor ebx, ebx
    ret

atoi_end:
        mov ebx, 1
    ret

; ------------------------- ;

; eax[in] - int32_t n
;
; eax[out] - int8_t log2(n)
log2:
          xor ecx, ecx

    repeat 32
          mov ebx, eax
          and ebx, [mask] ; Проверка на то,
          cmp ebx, [mask] ; является ли первый
      je log2_early       ; бит 1

          inc ecx
          shl eax, 1
    end repeat

    ret                  ; В eax к этому моменту 0

log2_early:
        mov eax, 32      ; Максимальный размер eax - 32 бита
        sub eax, ecx     ; Каждой смещение - деление на 2(степень уменьшается на 1)
        dec eax          ; Возвращаем 32 - расстояние до первой единицы - 1
    ret

; ------------------------- ;

; eax[in] - a
; ecx[in] - b
;
; eax[out] - |a-b|
abs_diff:
        cmp eax, ecx
    jl abs_diff_less

        sub eax, ecx
    ret 

abs_diff_less:
        sub ecx, eax
        mov eax, ecx
    ret
    
; ------------------------- ;

section '.idata' import readable
  library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
  import  kernel,\
      ExitProcess,  'ExitProcess',\
      GetStdHandle,  'GetStdHandle',\
      WriteConsole,  'WriteConsoleA',\
      ReadConsole,  'ReadConsoleA',\
      GetCurrentDirectory,  'GetCurrentDirectoryA',\
      CloseHandle,  'CloseHandle',\
      CreateFile,    'CreateFileA',\
      ReadFile,    'ReadFile',\
      WriteFile,    'WriteFile',\
      GetCommandLine,  'GetCommandLineA',\
      VirtualFree,  'VirtualFree',\
      VirtualAlloc,  'VirtualAlloc',\
      SetFilePointer,  'SetFilePointer',\
      GetFileSize,  'GetFileSize'
  import msvcrt,\
      getch, '_getch',\
      printf, 'printf'
