; Длина строки
; Назначение программы: поиск длины строки, введеной в консоль.
; За символ в строке принимается один байт


format PE console

entry start
include 'C:\fasm\INCLUDE\win32a.inc'

section '.code' code readable executable

; Параметры:
; eax [вход] - ссылка на строку, \0
; ecx [выход] - длина строки

lenstr:
        xor ecx, ecx ; Обнуляем счетчик длины

lenstr_loopstart:
        cmp byte[eax+ecx], 0
    jz lenstr_loopexit ; Если ecx-ый байт строки - 0 заканчиваем цикл
        inc ecx
    jmp lenstr_loopstart ; Иначе - инкреминтируем счетчик и продолжаем цикл

lenstr_loopexit:
        ret

; Перевод из числа в строку в десятичной системе для вывода в консоль
; Параметры:
; eax [вход] - число для преобразования
; ecx [выход] - итоговая длина строки (количество цифр в числе)
itoa:
        xor ecx, ecx ; Обнуляем счетчик

itoa_loopstart:
        mov ebx, 10 ; Делитель
        xor edx, edx ; Обнуляем часть делимого edx:eax
        idiv ebx

        add dl, 48 ; Перевод цифры остатка в ascii
        mov byte[itoa_buffer+ecx], dl ; Сохраняем ascii - символ в массив

        inc ecx ; Увеличиваем длину строки
        cmp eax, 0
    jg itoa_loopstart ; Продолжаем цикл, если eax > 0

reverse:
        push ecx ; Сохраняем длину строки
        xor esi, esi ; Обнуляем левый индекс
        mov edi, ecx
        dec edi ; Делаем правый индекс равным длине строки - 1

reverse_loop:
        mov al, byte[itoa_buffer+edi]
        mov bl, byte[itoa_buffer+esi]
        mov byte[itoa_buffer+edi], bl 
        mov byte[itoa_buffer+esi], al ; Меняем местами элементы по правому и по левому индексу

        inc esi ; Увеличиваем левый индекс
        dec edi ; Уменьшаем правый индекс

        cmp esi, edi
    jl reverse_loop ; Если левый индекс меньше правого - продолжаем итерацию
        pop ecx ; Восстанавливаем длину строки

    ret

; Точка входа
start:
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov [stdout_handle], eax ; Получаем и сохраняем stdout handle

        invoke GetStdHandle, STD_INPUT_HANDLE
        mov [stdin_handle], eax ; Получаем и сохраняем stdin handle

        invoke WriteFile, [stdout_handle], input_message, input_message_len, 0, 0 ; Выводим сообщение о готовности получать строку
        invoke ReadFile, [stdin_handle], input_string, 1023, 0, 0 ; Считываем
        ; строку (оставляя в буффере как минимум один байт под \0, чтобы избежать
        ; неправильной обработки строки без \0)

        invoke WriteFile, [stdout_handle], strlen_message, strlen_message_len, 0, 0 ; Выводим сообщение о длине строки
        
        mov eax, input_string
        call lenstr ; Вызываем процедуру для подсчета длины строки
        mov eax, ecx 
        call itoa ; Вызываем процедуру для преобразования числа в ascii
        invoke WriteFile, [stdout_handle], itoa_buffer, ecx, 0, 0 ; Выводим длину строки

        invoke ReadFile, [stdin_handle], input_string, 1, 0, 0 ; Ждем ввода пользователя

exit:
        invoke ExitProcess, 0 ; Завершаем программу с кодом 0

section '.data' readable writeable

stdout_handle dd 0 ; Место для handle stdout
stdin_handle dd 0 ; Место для handle stdin
input_message db 'Enter the string: ' ; Сообщение о готовности получать строку
input_message_len = $-input_message ; Длина сообщения о готовности получать строку
strlen_message db 'String length: ' ; Сообщение о длине строки
strlen_message_len = $-strlen_message ; Длина сообщения о длине строки

input_string db 1024 dup(0) ; Буффер для введенной пользователем строки
itoa_buffer db 11 dup(0) ; Буффер для конвертации строки в массив ascii
; символов (11 символов достаточно для 32-х битного числа)


section '.idata' import data readable writeable
library kernel32, 'kernel32.dll'
import kernel32, \
    GetStdHandle, 'GetStdHandle',\
    WriteFile, 'WriteFile',\
    ReadFile, 'ReadFile',\
    ExitProcess, 'ExitProcess'
