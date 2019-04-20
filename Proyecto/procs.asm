procedimientos segment
public 
assume cs:procedimientos
	imprimir proc far
		pop bx
		pop cx
		pop dx
		push bx
		push cx
		mov ah, 09h
		int 21h
	retf
procedimientos endS
 end