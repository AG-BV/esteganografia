include macro.asm
;------------------------------------------------------------------------------

Pila Segment
 db 0FFFFh Dup (?)
Pila EndS

;------------------------------------------------------------------------------

Datos Segment
	filename db 'star.bmp',0
	clave db 'hola'
	
	paleta 	db 00h, 04h, 02h, 06h, 01h, 05h, 03h, 07h, 08h, 0Ch, 0Ah, 0Eh, 9h, 0Dh, 0Bh, 0Fh
	
	filehandle dw ?

	Header db 118 dup (0)
	Header2 db 640 dup (0)
	ColorCommand db ?

	ancho dw ?
	largo dw ?

	ErrorMsg db 'Error', 13, 10,'$'
Datos EndS

Codigo Segment
Assume CS:Codigo, DS:Datos

sumadorC proc near
	
	
	
sumadorC endp

busqueda proc near
	pop cx
	pop ax
	push cx
	mov al, ah
	xor ah, ah
	lea bx, paleta
	xlat
	mov ColorCommand, al
	ret
endP

OpenFile proc
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h

	jc openerror
	mov [filehandle], ax
	ret

	openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h

	ret
endp OpenFile

ReadHeader proc
	mov ah,3fh
	mov bx,[filehandle]
	mov cx,118
	mov dx,offset Header
	int 21h
	
	push ax
	mov ah, [Header]+19
	mov al, [Header]+18
	mov ancho, ax
	
	mov ah, [Header]+23
	mov al, [Header]+22
	mov largo, ax
	pop ax
	
	mov ah,3eh 
	mov bx,FileHandle 
	int 21h
	
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	
	mov ah,3fh
	mov bx,[filehandle]
	mov cx,118
	mov dx,offset Header
	int 21h
	
	ret
endp ReadHeader

pintar proc
	mov ah, 00h
	mov al, 12h
	int 10h 
	mov dx, 1E0H
	push dx
ploop:

	mov ax,3f00h
	mov bx,[filehandle]
	mov cx,140h
	mov dx,offset Header2
	int 21h
	lea si, [header2]
	pop dx
	cmp dx, 0
	jz final
	mov cx, 0
	sloop:
		cmp cx, 280h
		jz floop
		mov al, byte ptr [si]
		mov ah, byte ptr [si]
		inc si
		and al, 00001111b
		and ah, 11110000b
		rol Ah, 4
		mov bx, ax
		push bx
		;---------
		xor ax,ax
		ppila
		pintarM
		;---------
		inc cx
		pop bx
		mov bh, bl
		ppila
		pintarM
		inc cx
		;---------
		jmp sloop
floop:
	dec dx
	push dx
	jmp ploop
endp pintar

Inicio:
	mov ax, datos
	mov ds, ax
	
	call
	
	;call openFile
	;call ReadHeader
	;call pintar

final:
	mov ah,3eh
	mov bx,FileHandle
	int 21h

	mov ah,10h
	int 16h
	
	mov ax,0003h
	int 10h
	
	mov ax, 4C00h
	int 21h
Codigo EndS
	End Inicio