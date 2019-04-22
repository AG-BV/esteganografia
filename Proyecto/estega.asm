;-------------------------------------------;
;Tecnologico de Costa Rica                  ;
;Escuela de Ingenieria en Computacion       ;
;Proyecto Programado BMP                    ;
;Estudiante: 	201058379                   ;
;             	2014130122                  ;
;Descripcion:  Esteganografia en BMP        ;
;                                           ;
;                                           ;
; FUM: abril 14, 2019.                      ;
;-------------------------------------------;
extrn Print:Far
Pila Segment
	dw 256 dup (?)
Pila EndS

Datos Segment
	texto db "HOLA$"
	bmp db "ACA DEBERIA CAMBIAR EL VALOR DE LAS COSAS EN EL TEXTO",'$'
	valor db ?
Datos EndS
Codigo Segment
	assume  cs:Codigo, ds:Datos, ss:Pila

PrepareNible proc far
	mov ah, byte ptr[di]
	mov al, byte ptr[di]
	;Mascaras para los nibles
	and ah, 11110000b
	and al, 00001111b
	rol al, 4 ;lo dejamos en la parte alta para
				  ;resulte sencillo manipular el LSB
	retf
PrepareNible Endp

PreparePixel proc far
	mov dh, byte ptr[si]
	mov dl, byte ptr[si]
	;Mascaras para los nibles
	and dh, 11110000b
	and dl, 00001111b
	rol dh, 4 ;lo dejamos en la parte baja para
			  ;resulte sencillo manipular el LSB
	retf

PreparePixel Endp
ProcesoBits proc Far

	and ah, 000000001b
	and al, 000000001b
	call PreparePixel
	and dh, 00000001b
	and dl, 00000001b
	Pixel1:
		cmp dh, ah
		jz Igual1
		jg Apagar1
		jl Encender1
	Pixel2:
		cmp dl, al
		jz Igual2
		jg Apagar2
		jl Encender2
	Igual1:
		mov dh, byte ptr [si]
		and dh, 11110000b
		jmp Pixel2		
	Igual2:
		mov dl, byte ptr [si]
		and dl, 00001111b
		jmp SalirProceso
	Apagar1:
		mov dh, byte ptr [si]
		and dh, 11110000b
		rol dh, 4
    	and dh, 11111110b
    	jmp Pixel2		
	Apagar2:
		mov dl, byte ptr [si]
		and dl, 00001111b
    	and dl, 11111110b

    	jmp SalirProceso

    Encender1:
		mov dh, byte ptr [si]
		and dh, 11110000b
		rol dh, 4
    	or dh, 00000001b
  
    	jmp Pixel2	
    Encender2:
		mov dl, byte ptr [si]
		and dl, 00001111b
    	or dl, 00000001b
    		;mov bmp[di], dh
    	jmp SalirProceso

    SalirProceso:
    	retf
ProcesoBits Endp
ProcesoLSB proc Far
	Compare:
		cmp cx, 4
		jz Principal
		rol ah, 1
		rol al, 1
		push ax
		call ProcesoBits
		add dh, dl
		mov byte ptr[si], dh
		inc si
		inc cx
		pop ax
		jmp Compare
	Principal:
		retf
ProcesoLSB Endp
	Inicio:
		    mov ax, datos   ; protocolo de inicialización del programa.
         	mov ds, ax

         	;extraemos el primer nible de la letra H (0100)

         	lea di, texto ;apuntamos el si al inicio de la texto
         				  ;prevista para ciclos 
         	lea si, bmp ;


    LSB: 
    	cmp texto[di], '$'
    	jz Salir
    	call PrepareNible
    	call ProcesoLSB
    	inc di
    	xor cx, cx
    	jmp LSB
    Salir:

    		mov ax, 4c00h
    		int 21h
Codigo EndS
	End Inicio