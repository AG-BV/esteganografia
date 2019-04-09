;------------------------------------------------------------------------------

Pila Segment
 db 0FFFFh Dup (?)
Pila EndS

;------------------------------------------------------------------------------

Datos Segment
	num1 db 0
	num2 db 0
	resp db 0,"$"
	p1 db 10, 13, "Digite primer numero: ", "$"
	p2 db 10, 13, "Digite segundo numero: ", "$"
	r1 db 10, 13, "Resultado: ", "$"

Datos EndS

;------------------------------------------------------------------------------

Codigo Segment
ASSUME CS:Codigo, DS:Datos

Inicio:
	xor ax,ax
	mov ax,datos
	mov ds,ax

	mov ax,4c00h
	int 21h
	
Codigo EndS
	End Inicio