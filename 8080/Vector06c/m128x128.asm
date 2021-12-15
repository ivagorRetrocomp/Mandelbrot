;Mandelbrot 128x128 with zoom for Vector06c
;Ivan Gorodetsky
;v 1.0 - 15.12.2021 (320 bytes)
;
;Compile with The Telemark Assembler (TASM) 3.2


SQRTab	.equ 1000h
MAXITER .equ 8
VIEW_R	.equ -512;
VIEW_I	.equ -2048;
DXY0	.equ 32

Mask	.equ 11111b		;for scale=256

		.org 0100h

		di
		lxi h,0038h
		mvi m,0C9h
		mvi h,7Fh
		xra a
		out 10h
		sphl
Cls:
		mov m,a
		inx h
		cmp h
		jnz Cls
		ei
		hlt
		mvi a,88h
		out 0
		mvi a,7
SetPal:
		out 2
		out 0Ch
		rst 7
		rst 7
		rst 7
		out 0Ch
		dcr a
		jp SetPal
	
		xra a
		xchg
		lxi b,-1
		push psw
MakeSQRTabLoop:
		pop psw
SetTabAdr1:
		lxi h,SQRTab
		mov m,d
		inx h
		mov m,a
		inx h
		shld SetTabAdr1+1
SetTabAdr2:
		lxi h,SQRTab+8192+1
		mov m,a
		dcx h
		mov m,d
		dcx h
		shld SetTabAdr2+1
		inx b
		inx b
		xchg
		dad b
		xchg
		aci 0
		push psw
		ani 40h
		jz MakeSQRTabLoop
		pop psw
		mov m,a
		dcx h
		mov m,d

MainLoop:
SetVIEW_I:	
		lxi h,VIEW_I
MainLoop1:
		shld SetVIEW_I+1
Loopyy:
		shld c_i
		lxi h,VIEW_R
Loopxx:
		shld c_r
		shld z_r
		push h
		lhld c_i
		shld z_i
		pop h
		mvi a,MAXITER-1
Loopiter:
		push psw
		call SQR
		mov c,m
		inx h
		mov b,m			;BC=z_r2
z_i		.equ $+1
		lxi h,0
		call SQR
		mov e,m
		inx h
		mov d,m			;DE=z_i2
		mov l,e
		mov h,d
		dad b			;HL=z_r2+z_i2
		mvi a,3
		cmp h
		jc breakiter
		push d			;z_i2
		push h			;z_r2+z_i2
z_r		.equ $+1
		lxi d,0
		lhld z_i
		dad d			;HL=z_r+z_i
		call SQR
		mov a,m
		inx h
		mov d,m			;DA=(z_r+z_i)^2
		pop h
		sub l
		mov l,a
		mov a,d
		sbb h
		mov h,a			;HL=(z_r+z_i)^2-(z_r2+z_i2)
c_i		.equ $+1
		lxi d,0
		dad d
		shld z_i		;z_i=(z_r+z_i)^2-z_i2-z_r2+c_i
		pop h			;z_i2
		mov a,c
		sub l
		mov l,a
		mov a,b
		sbb h
		mov h,a			;HL=z_r2-z_i2
c_r		.equ $+1
		lxi d,c_r
		dad d
		shld z_r		;z_r=z_r2-z_i2+c_r
		pop psw
		dcr a
		jnz Loopiter
		push psw
breakiter:
ScrAdr	.equ $+1
		lxi h,0E000h
		pop d
		mov e,h
Pixel:
		mov a,d
		rrc
		mov d,a
PixMask	.equ $+1
		mvi a,00111111b
		mov b,a
		cma
		jc $+4
		xra a
		mov c,a
		mov a,m\ ana b\ ora c\ mov m,a
		dcr l
		mov m,a
		inr l
		mvi a,-32\ add h\ mov h,a
		cpi 0A0h
		jnc Pixel
		mov a,b			;PixMask
		rrc
		rrc
		sta PixMask
		mov a,e
		cmc
		aci 0
		sta ScrAdr+1
		lhld c_r
DXY		.equ $+1
		lxi d,DXY0
		dad d
		jnz Loopxx
		lhld ScrAdr
		mvi h,0E0h
		dcr l
		dcr l
		shld ScrAdr
		lhld DXY
		xchg
		lhld c_i
		dad d
		jnz Loopyy
		mov a,e
SetZoom:
		jmp ZoomIn
SQR:
		dad h
		mvi a,Mask\ ana h\ adi SQRTab>>8\ mov h,a
		ret
ZoomIn:
		rar\ sta DXY
		dcr a
		jnz NoZoom1
		mvi a,ZoomOut&255
		sta SetZoom+1
NoZoom1:
		lhld SetVIEW_I+1
		mov a,h\ stc\ rar\ mov h,a
		mov a,l\ rar\ mov l,a
		jmp MainLoop1
ZoomOut:
		add a\ sta DXY
		cpi 32
		jnz NoZoom32
		mvi a,ZoomIn&255
		sta SetZoom+1
NoZoom32:
		lhld SetVIEW_I+1
		dad h
		jmp MainLoop1

		.end
