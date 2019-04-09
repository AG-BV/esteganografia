Datos Segment
	archivo db 'a.txt0'
	handle dw ?
	errorm db 10, 13, 'Se ha producido un error $'
Datos EndS
Codigo Segment
assume CS: Codigo, DS:Datos
Inicio:
	mov ax, Datos
	push ax
	pop ds

	mov ax, 3Ch
	mov cx, 32d
	lea dx, archivo
	int 21h

	jc Error
	mov handle, ax
	mov ah, 3eh
	mov bx, handle
	jc Error
	jmp short Salir

Error:
	mov ah, 09h
	lea dx, errorm

Salir:
	mov ax, 4c00h
	int 21h

Codigo EndS
	End Inicio