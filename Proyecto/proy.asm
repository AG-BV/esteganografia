include macro.asm
;------------------------------------------------------------------------------

Pila Segment
 db 0FFFFh Dup (?)
Pila EndS

;------------------------------------------------------------------------------

Datos Segment
	ce db 4
	filename db 255 dup (?)
			 db 0
	clave db 255 dup (?)
	sclave dw ?
	lclave dw ?
	fila dw ?
	columna dw ?
	extension dw ?
	texto db 255 dup (?)
	
	paleta 	db 00h, 04h, 02h, 06h, 01h, 05h, 03h, 08h, 07h, 0Ch, 0Ah, 0Eh, 9h, 0Dh, 0Bh, 0Fh
	
	fileH dw ?

	Header db 118 dup (0)
	Header2 db 640 dup (0)
	Header3 db 16 dup (0)
	ColorCommand db ?
	LineCommand db    0FFh Dup (?)
			db '$'

	ancho dw ?
	largo dw ?

	msg1 db '--------Programa esteganografia--------'
	msg2 db 10,13,'Formato de uso: estega /e /t:"texto" /? /d /c:"clave" /bmp:"archivo.bmp"'
	msg3 db 10,13,'/h o /H Ayuda'
	msg4 db 10,13,'/e o /E Esteganografiar el mensaje "texto" con la "clave" en el "bmp"'
	msg5 db 10,13,'/d o /D Desencriptar el mensaje con la "clave" en el bmp'
	msg6 db 10,13,'"archivo" Es el nombre del archivo debe ser un bmp de 16 colores'
	msg7 db 10,13,'estega /bmp:"archivo.bmp" para mostrar imagen$'
	
	var1 db '/h'
	var2 db '/e'
	var3 db '/d'
	var4 db '/bmp'
Datos EndS

Codigo Segment
Assume CS:Codigo, DS:Datos

imprimir proc near
	mov ah, 09h
	lea dx, msg1
	int 21h
	ret
imprimir endp

sumaD proc near
	pop ax
	pop cx
	push ax
	xor bx, bx
	cicloSuma:
		cmp bx, 10h
		jz salirSumaD
		inc cx
		inc bx
		jmp cicloSuma
	
	salirSumaD:
		pop ax
		push cx
		push ax
		ret
sumaD endp

desencriptarPal proc near
	lea si, texto
	cicloDes:
		mov al, byte ptr [si]
		cmp al, "$"
		jz salidaDes
		sub al, ce
		mov byte ptr [si], al
		inc si
		jmp cicloDes
	
	salidaDes:
		ret
desencriptarPal endp

encriptarPal proc near
	lea si, texto
	cicloEnc:
		mov al, byte ptr [si]
		cmp al, "$"
		jz salidaEnc
		add al, ce
		mov byte ptr [si], al
		inc si
		jmp cicloEnc
	
	salidaEnc:
		ret
encriptarPal endp

escribir proc near
	mov si, 0000h
	mov ah,40h
	mov bx,[fileH]
	mov cx,extension
	lea dx,texto
	int 21h
	ret
escribir endp

ubicadorD proc near
	mov ax, sclave
	mov bx, sclave
	and ax, 1111111111110000b
	and bx, 0000000000001111b
	mov fila, ax
	mov columna, bx
	mov ah,3fh
	mov bx,[fileH]
	mov cx,16
	mov dx,offset Header3
	int 21h
	xor cx,cx

	bfilaD:
		cmp cx, fila
		jz procesoCD
		push cx
		mov ah,3fh
		mov bx,[fileH]
		mov cx,16
		mov dx,offset Header3
		int 21h
		call sumaD
		pop cx
		jmp bfilaD
		
	procesoCD:
		xor ax,ax 
		xor cx,cx
		xor si,si 
		lea si, [Header3]
	bcolumnaD:
		cmp cx, columna
		jz salidaUD
		mov al, byte ptr [si]
		inc cx
		inc si
		jmp bcolumnaD
		
	salidaUD:
		pop ax
		push si
		push ax
		lea di, texto
		ciclo1:
			mov ah,3fh
			mov bx,[fileH]
			mov cx,16
			mov dx,offset Header3
			int 21h
			lea si, Header3
			xor cx, cx
			push cx
			ciclo2:
				pop cx
				cmp byte ptr [si], 24h
				jz salidaD
				cmp cx, 16
				jz ciclo1
				mov al, byte ptr [si]
				mov byte ptr [di], al
				inc si
				inc di
				inc cx
				push cx
				jmp ciclo2
		
	salidaD:
		mov al, byte ptr [si]
		mov byte ptr [di], al
		call desencriptarPal
		imprimirP texto
		ret
ubicadorD endp

ubicador proc near
	mov ax, sclave
	mov bx, sclave
	and ax, 1111111111110000b
	and bx, 0000000000001111b
	mov fila, ax
	mov columna, bx
	mov ah,3fh
	mov bx,[fileH]
	mov cx,16
	mov dx,offset Header3
	int 21h
	xor cx,cx

	bfila:
		cmp cx, fila
		jz procesoC
		push cx
		mov ah,3fh
		mov bx,[fileH]
		mov cx,16
		mov dx,offset Header3
		int 21h
		call sumaD
		pop cx
		jmp bfila
		
	procesoC:
		xor ax,ax 
		xor cx,cx
		xor si,si 
		lea si, [Header3]
	bcolumna:
		cmp cx, columna
		jz salidaU
		mov al, byte ptr [si]
		inc cx
		inc si
		jmp bcolumna
		
	salidaU:
		pop ax
		push si
		push ax
		call encriptarPal
		call escribir
		ret
ubicador endp

sumadorC proc near
	lea si, clave
	xor cx,cx
	mov al, byte ptr [si]
	inc si
	inc cx
	xor ah,ah
	mov sclave, ax
	cmp al, '$'
	jz fciclo
		
	ciclo:
		mov bl, byte ptr [si]
		cmp bl, '$'
		jz fciclo
		xor bh,bh
		add sclave, bx
		inc si
		inc cx
		jmp ciclo
		
	fciclo:
	mov lclave, cx
	mov ax, sclave
	sciclo:
		cmp cx, 0000h
		jz salir
		add sclave, ax
		dec cx
		jmp sciclo
	
	salir:
		ret	
		
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

abrirArchivo proc
	mov ah, 3Dh
	mov al, 02h
	mov dx, offset filename
	int 21h
	mov [fileH], ax
	ret
endp abrirArchivo

leerH proc
	mov ah,3fh
	mov bx,[fileH]
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
endp leerH

pintar proc
	mov ah, 00h
	mov al, 12h
	int 10h 
	mov dx, 1E0H
	push dx
ploop:

	mov ax,3f00h
	mov bx,[fileH]
	mov cx,140h
	mov dx,offset Header2
	int 21h
	lea si, [Header2]
	pop dx
	cmp dx, 0
	jz re
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
	
re:	
	mov ah,1
	int 21h
	
	mov ah, 0
	mov al, 2
	int 10h
	
	mov ah,3eh
	int 21h
	
	ret
endp pintar

GetCommanderLine Proc Near
	LongLC    EQU   80h
	ListPush  <Es, Di, Si, Cx, Bp>
	Mov   Bp,Sp
	Mov   Ax,Es
	Mov   Ds,Ax
	Mov   Di,12[Bp]
	Mov   Ax,14[Bp]
	Mov   Es,Ax
	Xor   Cx,Cx
	Mov   Cl,Byte Ptr Ds:[LongLC]
	Mov   Si,2[LongLC]
	Rep   Movsb
	ListPop <Bp, Bx, Si, Di, Es>
	Ret   14
GetCommanderLine EndP

Inicio:
	Mov   Ax,Seg LineCommand
	Push  Ax
	Lea   Ax,LineCommand
	Push  Ax
	Call  GetCommanderLine

	mov ax, datos
	mov ds, ax
	push es
	mov es, ax
	
	comparar LineCommand, var1
	jz ayuda
	
	comparar LineCommand, var2
	jz encriptar
	
	comparar LineCommand, var3
	jz desencriptar
	
	comparar LineCommand, var4
	call mostrarI
	
	ayuda:
		call imprimir
		jmp final
	
	encriptar:
		lea si, LineCommand+6
		mov al, byte ptr [si]
		lea di, texto
		xor cx,cx
		cTexto:
			cmp byte ptr [si], 20h
			jz sTexto
			mov al, byte ptr [si]
			mov byte ptr [di], al
			inc si
			inc di
			inc cx
			jmp cTexto
		
		sTexto:
			mov byte ptr [di], 24h
			inc cx
			mov extension, cx
			inc si
			inc si
			inc si
			inc si
			lea di, clave
			cClave:
				cmp byte ptr [si], 20h
				jz saClave
				mov al, byte ptr [si]
				mov byte ptr [di], al
				inc si
				inc di
				jmp cClave
		
		saClave:
			mov byte ptr [di], 24h
			inc si
			inc si
			inc si
			inc si
			inc si
			inc si
			lea di, filename
			cImag:
				cmp byte ptr [si], 0Dh
				jz salidaLector
				mov al, byte ptr [si]
				mov byte ptr [di], al
				inc si
				inc di
				jmp cImag
		
		salidaLector:
			call abrirArchivo
			call sumadorC
			call ubicador
			jmp final
	
	desencriptar:
		lea si, LineCommand+6
		lea di, clave
		mov al, byte ptr [si]
		dclave:
			cmp byte ptr [si], 20h
			jz sadClave
			mov al, byte ptr [si]
			mov byte ptr [di], al
			inc si
			inc di
			jmp dClave
		
		sadClave:
			mov byte ptr [di], 24h
			inc si
			inc si
			inc si
			inc si
			inc si
			inc si
			lea di, filename
			dciImag:
				cmp byte ptr [si], 0Dh
				jz salidaDesenciptar
				mov al, byte ptr [si]
				mov byte ptr [di], al
				inc si
				inc di
				jmp dciImag
		
		salidaDesenciptar:
			call abrirArchivo
			call sumadorC
			call ubicadorD
			jmp final
		
mostrarI proc near
	lea si, LineCommand+5
	lea di, filename
	mov al, byte ptr [si]
	ciMostrar:
		cmp byte ptr [si], 0Dh
		jz salidaMostrar
		mov al, byte ptr [si]
		mov byte ptr [di], al
		inc si
		inc di
		jmp ciMostrar

mostrarI endp
		
salidaMostrar:	
	call abrirArchivo
	call leerH
	call pintar
	jmp final
		
final:
	mov ax, 4C00h
	int 21h
Codigo EndS
	End Inicio