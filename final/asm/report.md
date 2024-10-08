## Описание задачи

Написать dll программу, которая принимает на вход файл с записями амплитуд и количеств замеров. Классифицировать отношения между тремя количествами замеров, идущими друг за другом

## Входные данные

На вход подается файл с названием input.bin, содержащий n 4-х битных записей, где первые 2 бита - амплитуда, 3 бит - количество отсчетов по прямой, 4 бит - количество отсчетов по косой

## Выходные данные

Создается файл output.bin, в котроый последовательно записываются все номера отношений количеств отсчетов, данные файла дублируются в консоль

## Использование DLL

У DLL есть одна процедура - Wc, которая принимает на вход
in_buf - указатель на входной массив
buf_size - размер входного массива
out_buf - указатель на выходной массив

Dll записывает в выходной массив данные о номере отношений
Память под входной и выходной массив выделяется тем, кто обращается к dll,
Размер выходного массива должен быть не менее buf_size / 8

## Принцип работы

Входной файл считывается программой. Массив байтов файла подается в DLL. В каждой 4-х битной записи складываются количества отсчетов по прямой и по косой, получаются числа A, B, и C. Затем находятся численные представления отношений между A и B, B и C и C и A соответственно. Отношение меньше (<) представлено 0, равно (=) представлено 1 и меньше (<) представлено 2. После этого программа получает номер такого отношения при помощи массива lookup(см. листинг 1)

Листинг 1 - массив lookup

```
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
```
