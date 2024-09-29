; Задача - классифицировать количество замеров по трем точкам

format PE console DLL
entry DllEntryPoint

include 'C:\fasm\INCLUDE\win32a.inc'

section '.data' readable writeable
        max_iter dd 0
        current_position dd 0

        first dw 0
        second dw 0
        third dw 0

        first_cmp dw 0
        second_cmp dw 0
        third_cmp dw 0

        current_type dd 0

        ; Трехмерный массив со всеми классами сравниваемых чисел
        ; -1 отмечены ситуации, невозможные при трех сравненияих 3-х чисел
        lookup db  \
         -1, -1,  2, \   ; < < <, < < =, < < >
         -1, -1,  4, \   ; < = <, < = =, < = >
          9,  8, 10, \   ; < > <, < > =, < > >
         \
         -1, -1,  5, \  ; = < <, = < =, = < >
         -1,  3, -1, \  ; = = <, = = =, = = >
          6, -1, -1, \  ; = > <, = > =, = > >
         \
         12, 11, 13, \  ; > < <, < < =, > < >
          7, -1, -1, \  ; > = <, < = =, > = >
          1, -1, -1     ; > > <, < > =, > > >

section '.text' code readable executable

; Входная точка в DLL
proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
        mov	eax, 1
	ret
endp

; eax - a, ebx - b, ecx - c
; Возврвщает класс номеров отношений трех чисел A, B, C
; eax - первое отношение (между A и B)
; ebx - второе отношение (между B и C)
; ecx - трертье отношение (между C и A)
; Отношения двух чисел a и b представляются как
; 0 при a < b
; 1 при a = b
; 2 при a > b
get_type:
        movzx eax, al
        lea eax, [eax * 8 + eax] ; (eax = (al << 3) + al = 3 * 3 * al )

        movzx ebx, bl
        lea ebx, [ebx * 2 + ebx] ; (ebx = (bl << 1) + al = 3 * bl )

        movzx ecx, cl

        add eax, ebx 
        add eax, ecx
        ; (eax = 9al + 3bl + cl)

        movzx eax, byte [lookup + eax]
        ; eax = lookup[al][bl][cl]
	ret

; Возвращает численное представление отношения между a и b
; eax - a 
; ebx - b
; Отношения двух чисел a и b представляются как
; 0 при a < b
; 1 при a = b
; 2 при a > b
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

; Процедура для классификаций отношений
; in_buf - указатель на входной массив
; buf_size - размер входного массива 
; out_buf - указатель на выходной массив
proc Wc in_buf, buf_size, out_buf
; Запись масимального возможного значения,
; по которому не произойдет выход за границы массива
        mov eax, [buf_size]
        mov [max_iter], eax 
        sub [max_iter], 12

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

    ; Получение численного представления отношений первого и второого числа
        movzx eax, [first]
        movzx ebx, [second]
	call get_cmp
        mov [first_cmp], ax

    ; Получение численного представления отношений второого и третьего числа
        movzx eax, [second]
        movzx ebx, [third]
	call get_cmp
        mov [second_cmp], ax

    ; Получение численного представления отношений третьего и первого числа
        movzx eax, [third]
        movzx ebx, [first]
	call get_cmp
        mov [third_cmp], ax

    ; Получение номера отношений трех чисел
        movzx eax, [first_cmp]
        movzx ebx, [second_cmp]
        movzx ecx, [third_cmp]
	call get_type
        mov [current_type], eax
        mov ebx, [out_buf]
        mov ecx, [current_position]
        mov byte [ebx+ecx], al

        add [current_position], 1
        pop ecx

    ; Пропуск двух записей сразу, чтобы не было перекрытия
        add ecx, 8

        cmp ecx, [max_iter]
	jl mainloop

        mov eax, [current_position]
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
