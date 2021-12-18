;Mandelbrot 128x128 with zoom for Vector06c
;Ivan Gorodetsky
;v 1.0 - 15.12.2021 (320 bytes)
;v 1.1 - 17.12.2021 (289 bytes and slightly faster)
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
		sphl
		ei
		hlt
		mvi a,88h
		out 0
		mvi c,15
SetPal:
		mov a,c
		out 2
		ani 7
		out 0Ch
		rst 7
		rst 7
		rst 7
		out 0Ch
		dcr c
		jp SetPal
		out 10h
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
		dcx h
		mov m,d

ZoomIn:
		rar
		mov c,a
		dcr a
		jnz NoZoom1
		lxi h,SetZoom
		dcr m
NoZoom1:
SetVIEW_I:	
		lxi h,VIEW_I*2
		mov a,h\ stc\ rar\ mov h,a
		mov a,l\ rar\ mov l,a
		mov a,c
MainLoop:
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
		mov e,m
		inx h
		mov d,m			;DE=z_i2
z_r		.equ $+1
		lxi h,0
		call SQR
		mov c,m
		inx h
		mov b,m			;BC=z_r2
		mov l,e
		mov h,d
		dad b			;HL=z_r2+z_i2
		mvi a,3
		cmp h
		jc breakiter
		mov a,c
		sub e
		mov e,a
		mov a,b
		sbb d
		mov d,a			;DE=z_r2-z_i2
		push d			;z_r2-z_i2
		push h			;z_r2+z_i2
z_i		.equ $+1
		lxi d,0
		lhld z_r
		dad d			;HL=z_r+z_i
		call SQR
		mov a,m
		inx h
		mov d,m			;DA=(z_r+z_i)^2
		pop h			;z_r2+z_i2
		sub l
		mov l,a
		mov a,d
		sbb h
		mov h,a			;HL=(z_r+z_i)^2-(z_r2+z_i2)
c_i		.equ $+1
		lxi d,0
		dad d
		xthl
						;HL=z_r2-z_i2
c_r		.equ $+1
		lxi d,c_r
		dad d
		shld z_r		;z_r=z_r2-z_i2+c_r
		pop h
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
		jmp MainLoop
SQR:
		dad h
		mvi a,Mask\ ana h\ adi SQRTab>>8\ mov h,a
		ret
		
		.end
