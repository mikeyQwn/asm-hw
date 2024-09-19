format PE Console

entry start
include 'C:\FASM\INCLUDE\win32a.inc'

section '.data' data readable writeable
  default_msg db 'DEFAULT MESSAGE', 0xA, 0
  jump_msg db 'JUMP MESSAGE', 0xA, 0
  buffer db 1024 dup 0

label_list equ

macro new_label item {
   match any, label_list \{ label_list equ label_list,item \}
   match , label_list \{ label_list equ item \}
   item:
}

macro prepend_label item {
   match any, label_list \{ label_list equ item,label_list \}
   match , label_list \{ label_list equ item \}
   item:
}

macro print_list nlist1
{     common match nlist, nlist1
      \{ common irps token,nlist
      \\{
      common display \\`token
      \\}
      \}
}


section '.code' code readable executable
start:
	jmp jump_here

    invoke printf, default_msg

    invoke ExitProcess, 0

new_label jump_here
    invoke printf, jump_msg

    invoke ExitProcess, 0

new_label jump_here1
new_label jump_here2
prepend_label jump_here3

print_list label_list

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
