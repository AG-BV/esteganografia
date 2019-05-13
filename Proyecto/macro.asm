pintarM macro
	mov ah, 0Ch
	mov al, ColorCommand; color
	mov bh, 0
	int 10h
endm

ppila macro
	push cx
	push bx
	call busqueda
	pop cx
endm

ListPush  Macro lista
    IRP i,<lista>
		Push i
    EndM
EndM

ListPop  Macro lista
	IRP i,<lista>
		Pop i
	EndM
EndM

comparar Macro line, var
	mov cx, 2
	lea di, line
	lea si, var
	rep cmpsb
endM

imprimirP macro msj
	mov ah, 09h
	lea dx, msj
	int 21h
endM