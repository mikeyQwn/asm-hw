format PE Console

entry start
include 'C:\FASM\INCLUDE\win32a.inc'

bits = 1

macro create_msg id {
	if id = 0
	  out_msg db 'Hello, world: %d', 0xA, 0
	end if
	if id = 1
	  out_msg db 'Hello, world1: %d', 0xA, 0
	end if
}

section '.data' data readable writeable
  create_msg bits
  out_msg_len = $ - out_msg
  buffer db 1024 dup 0

section '.code' code readable executable
start:
    invoke printf, out_msg, 5

    invoke ExitProcess, 0

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
