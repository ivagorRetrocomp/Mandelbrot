;Mandelbrot 128x128 with zoom for PK6128c
;Ivan Gorodetsky
;v 1.1 - 17.12.2021 (256 bytes)
;
;Compile with The Telemark Assembler (TASM) 3.2


SQRTab	.equ 100h
MAXITER .equ 8
VIEW_R	.equ -512;
VIEW_I	.equ -2048;
DXY0	.equ 32

Mask	.equ 11111b		;for scale=256

		.org 0000h

		ei
		hlt
		lxi sp,8000h
		mvi c,7
SetPal:
		mov a,c
		out 2
		out 0Ch
		dcr c
		jp SetPal
		out 03
		mov d,a
		mov e,a
		mov b,c
MakeSQRTabLoop:
		rar
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
		add a
		jp MakeSQRTabLoop
		rar
		mov m,a
		mvi b,0C9h
ZoomIn:
		rar
		cpi 1
		jnz NoZoom1
		lxi h,SetZoom
		dcr m
NoZoom1:
SetVIEW_I:	
		lxi h,VIEW_I*2
		arhl
MainLoop1:
		sta DXY
		shld SetVIEW_I+1
Loopyy:
		shld c_i
		lxi h,VIEW_R
Loopxx:
		shld c_r
		shld z_r
		lhld c_i
		mvi d,MAXITER-1
Loopiter:
		shld z_i
		push d
		call SQR
		mov c,m
		inx h
		mov b,m			;BC=z_i2
z_r		.equ $+1
		lxi h,0
		call SQR
		xchg
		lhlx			;HL=z_r2
		dsub
		mov e,l
		mov d,h			;DE=z_r2-z_i2
		dad b
		dad b			;HL=z_r2+z_i2
		mvi a,3
		cmp h
		jc breakiter
		mov c,l
		mov b,h			;BC=z_r2+z_i2
c_r		.equ $+1
		lxi h,0
		dad d
		push h			;z_r2-z_i2+c_r
		lhld z_r
z_i		.equ $+1
		lxi d,0
		dad d			;HL=z_r+z_i
		call SQR
		xchg
		lhlx			;HL=(z_r+z_i)^2
		dsub			;HL=(z_r+z_i)^2-(z_r2+z_i2)
c_i		.equ $+1
		lxi d,0
		dad d
		xthl
		shld z_r		;z_r=z_r2-z_i2+c_r
		pop h			;z_i=(z_r+z_i)^2-z_i2-z_r2+c_i
		pop d
		dcr d
		jnz Loopiter
		.db 0FEh
breakiter:
		pop d
ScrAdr	.equ $+1
		lxi h,0E000h
		mov e,h
PixMask	.equ $+2
		lxi b,(11000000b*256)+0A0h
Pixel:
		mov a,d
		rrc
		mov d,a
		mov a,b
		jc $+6
		cma\ ana m\ .db 0FEh
		ora m
		mov m,a
		dcr l
		mov m,a
		inr l
		mvi a,-32\ add h\ mov h,a
		cmp c
		jnc Pixel
		mov a,b			;PixMask
		rrc
		rrc
		sta PixMask
		mvi a,0
		adc e
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
		lhld c_i
		dad d
		jnz Loopyy
		mov a,e
SetZoom:
		jmp ZoomIn
ZoomOut:
		add a
		cpi 32
		jnz NoZoom32
		lxi h,SetZoom
		inr m
NoZoom32:
		lhld SetVIEW_I+1
		dad h
		jmp MainLoop1
SQR:
		dad h
		mvi a,Mask\ ana h\ inr a\ mov h,a
		ret

		.end
