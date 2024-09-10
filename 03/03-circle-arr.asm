format PE console
entry start

include 'C:\fasm\INCLUDE\win32a.inc'

; Макрос для создания кольцевого массива
macro NewCircleArr NAME, SIZE {
    section '.data' data readable writeable
    NAME db SIZE dup 0 ; Объявление самого массива
    NAME#_size equ SIZE ; Объявление размера массива
    NAME#_write_ptr dd 0 ; Указатель на позицию записи
    NAME#_read_ptr dd 0 ; Указатель на позицию чтения
}

; Макрос для записи в кольцевой массив 
macro CircleArr_write NAME, VAL {
    mov eax, [NAME#_write_ptr] ; Получаем текущую позицию записи
    mov byte [NAME + eax], VAL ; Записываем значение в массив
    inc eax ; Увеличиваем позицию записи
    cmp eax, NAME#_size ; Проверяем, не достигнут ли конец массива
    jb @f ; Если не достигнут, переходим к метке @f
    xor eax, eax ; Если достигнут, сбрасываем позицию записи в 0
@@:
    mov [NAME#_write_ptr], eax ; Сохраняем новую позицию записи
}

; Макрос для чтения из кольцевого массива
macro CircleArr_read NAME {
    mov eax, [NAME#_read_ptr] ; Получаем текущую позицию чтения
    movzx eax, byte [NAME + eax] ; Читаем значение из массива
    inc dword [NAME#_read_ptr] ; Увеличиваем позицию чтения
    cmp [NAME#_read_ptr], NAME#_size ; Проверяем, не достигнут ли конец массива
    jb @f ; Если не достигнут, переходим к метке @f
    mov dword [NAME#_read_ptr], 0 ; Если достигнут, сбрасываем позицию чтения в 0
@@:
    invoke printf, read_fmt, eax ; Выводим прочитанное значение на экран
}

section '.data' data readable writeable
    read_fmt db "%c", 0xA, 0 ; Формат строки для printf

; Объявляем кольцевой массив 'arr' размером 5 байт
NewCircleArr arr, 5

section '.code' code readable executable
start:
    ; Записываем значения в кольцевой массив
    CircleArr_write arr, 'C'
    CircleArr_write arr, 'a'
    CircleArr_write arr, 'd'
    CircleArr_write arr, 'e'
    CircleArr_write arr, 't'
    CircleArr_write arr, 'o' ; Перезаписывает первое значение ('C')

    ; Читаем и выводим значения из кольцевого массива
    CircleArr_read arr ; Выводит 'o'
    CircleArr_read arr ; Выводит 'a'
    CircleArr_read arr ; Выводит 'd'
    CircleArr_read arr ; Выводит 'e'
    CircleArr_read arr ; Выводит 't'

    ; Ждем нажатия клавиши перед завершением
    invoke getch
    invoke ExitProcess, 0

section '.idata' import data readable writeable
    library kernel32, 'kernel32.dll', \
            msvcrt,   'msvcrt.dll'
    import kernel32, \
           ExitProcess, 'ExitProcess'
    import msvcrt, \
           printf, 'printf', \
           getch, '_getch'
