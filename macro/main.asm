; The ultimate goal is to understand this

list equ

macro append item {
    match any, list {
        list equ list,item
   \}
   match , list {
        list equ item
   \}
 }


macro Print nlist1
{     common match nlist, nlist1
      \{ common irps token,nlist
      \\{
      common display \\`token
      \\}
      \}
}

m1=1
m2=2
m3=3

append m1
append m2
append m3

Print list

