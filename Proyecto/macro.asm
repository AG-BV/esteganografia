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