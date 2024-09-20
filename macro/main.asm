; The ultimate goal is to understand this

label_list equ

macro append item
 {
   match any, label_list \{ label_list equ label_list,item \}
   match , label_list \{ label_list equ item \}
   item:
 }

macro Print nlist1
{     common match nlist, nlist1
      \{ common irps token,nlist
      \\{
      common display \\`token
      \\}
      \}
}

;m1=1
;m2=2
;m3=3

append m1
append m2
append m3

Print label_list


e equ 7       ; create equate stack
e equ 6       ; of digits
e equ 5

n=0           ; count # equates
irpv x, e {   ; iterate through stack
 n=n+1
}

;display \     ; display # equates
; '#', n+'0',\
; ':', ' '

start:
	xor eax, eax


bits = 16
display 'Current offset is 0x'
repeat bits/4
	d = '0' + $ shr (bits-%*4) and 0Fh
	if d > '9'
		d = d + 'A'-'9'-1
	end if
	display d
end repeat
display 13,10
