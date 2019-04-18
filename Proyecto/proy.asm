;------------------------------------------------------------------------------

Pila Segment
 db 0FFFFh Dup (?)
Pila EndS

;------------------------------------------------------------------------------

Datos Segment
	filename db 'leia.bmp',0

	filehandle dw ?

	Header db 118 dup (0)
	Header2 db 640 dup (0)

	ancho dw ?
	largo dw ?

	ErrorMsg db 'Error', 13, 10,'$'
Datos EndS

Codigo Segment
Assume CS:Codigo, DS:Datos

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
	; Read BMP file header, 54 bytes
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
		;---------
		xor ax,ax
		mov ah, 0Ch
		mov al, bh; color
		mov bh, 0
		int 10h
		inc cx
		mov ah, 0Ch
		mov al, bl; color
		mov bh, 0
		int 10h
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
	
	call openFile
	call ReadHeader
	call pintar

final:
	mov ah,10h
	int 16h
	
	mov ax,0003h
	int 10h
	
	mov ax, 4C00h
	int 21h
Codigo EndS
	End Inicio