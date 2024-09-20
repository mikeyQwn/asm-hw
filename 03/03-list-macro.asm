; Список меток
;
; Назначение программы: определение макроса, который создает метки 
; и записывает их в список, а так же макроса, который распечатывает список меток

format PE Console

entry start
include 'C:\FASM\INCLUDE\win32a.inc'

section '.data' data readable writeable
  default_msg db 'DEFAULT MESSAGE', 0xA, 0
  jump_msg db 'JUMP MESSAGE', 0xA, 0
  buffer db 1024 dup 0

; Объявляем список меток
label_list equ

; Макрос для создания метки
; Создает метку и добавляет ее в список меток
; Агрументы: item - название метки, которая создается
macro new_label item {
   match any, label_list \{ label_list equ label_list,item \}
   match , label_list \{ label_list equ item \}
   item:
}

; Макрос для создания метки
; Создает метку и добавляет ее в конец списка меток
; Агрументы: item - название метки, которая создается
macro prepend_label item {
   match any, label_list \{ label_list equ item,label_list \}
   match , label_list \{ label_list equ item \}
   item:
}

; Макрос для печати списка меток 
macro print_labels
{     common match nlist, label_list
      \{ common irps token,nlist
      \\{
      common display \\`token
      \\}
      \}
}


section '.code' code readable executable
; Используем макрос для создания метки start 
; Список меток на данный момент: `start`
new_label start
	; Делаем jmp на метку 'jump_here', чтобы проверить, что метка действительно создалась
	jmp jump_here

    invoke printf, default_msg ; Сообщение 'DEFAULT MESSAGE' не печатается
	; так как был совершен jmp на метку 'jump_here'

    invoke ExitProcess, 0

; Объявляем метку 'jump_here', на которую будет совершен jmp
; Список меток на данный момент: `start,jump_here`
new_label jump_here
    invoke printf, jump_msg ; Должно распечататься сообщение 'JUMP MESSAGE'

    invoke ExitProcess, 0

; Используем макрос для создания метки test1
; Список меток на данный момент: `start,jump_here,test1`
new_label test1
; Используем макрос для создания метки test2
; Список меток на данный момент: `start,jump_here,test1,test2`
new_label test2
; Используем макрос для создания метки test3 и добавления её в конец списка
; Список меток на данный момент: `test3,start,jump_here,test1,test2`
prepend_label test3

; Используем макрос для печати списка меток, получаем ожидаемый результат:
; `test3,start,jump_here,test1,test2`
print_labels

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
