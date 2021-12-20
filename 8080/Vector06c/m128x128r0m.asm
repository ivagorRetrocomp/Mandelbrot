;Mandelbrot 128x128 with zoom for Vector06c
;Ivan Gorodetsky
;v 1.11 - 20.12.2021 (256 bytes)
;
;Compile with The Telemark Assembler (TASM) 3.2


SQRTab	.equ 0700h
MAXITER .equ 8
VIEW_R	.equ -512;
VIEW_I	.equ -2048;
DXY0	.equ 32

Mask	.equ 11111b		;for scale=256

		.org 0000h

		ei
		hlt
		mvi a,88h
		out 0
		mvi c,7
		mov h,c
SetPal:
		mov a,c
		out 2
		out 0Ch
		rst 7
		rst 7
		dcr c
		out 0Ch
		jp SetPal
		mov d,a
		mov l,a
		sphl
		mov e,a
		mov b,c
MakeSQRTabLoop:
SetTabAdr1:
		mov m,d
		inx h
		mov m,a
		inx h
		inx b
		inx b
		xchg
		dad b
		xchg
		aci 0
		jmp SkipSQR
SQR:
		dad h
		mov a,h
		jnc SQRplus
		dcx h
		mov a,l\ cma\ mov l,a
		mov a,h\ cma
SQRplus:
		adi SQRTab>>8\ mov h,a
		ret
		nop
		ret
SkipSQR:
		jp MakeSQRTabLoop
		mvi a,DXY0
ZoomIn:
		rar
		mov c,a
		dcr a
		jnz NoZoom1
		lxi h,SetZoom
		dcr m
NoZoom1:
SetVIEW_I:
		lxi h,VIEW_I
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
		lxi d,0E000h+((MAXITER-1))
Loopiter:
		shld z_i
		push d
		rst 5
		mov e,m
		inx h
		mov d,m			;DE=z_i2
		lhld z_r
		rst 5
		mov c,m
		inx h
		mov b,m			;BC=z_r2
		mov a,c
		sub e
		mov l,a
		mov a,b
		sbb d
		mov h,a			;HL=z_r2-z_i2
		xchg			;DE=z_r2-z_i2
						;HL=z_i2
		dad b			;HL=z_r2+z_i2
		mvi a,3
		cmp h
		jc breakiter
		push h			;z_r2+z_i2
z_r		.equ $+1
		lxi b,0			;"old" z_r
c_r		.equ $+1
		lxi h,c_r
		dad d
		shld z_r		;new z_r=z_r2-z_i2+c_r
z_i		.equ $+1
		lxi h,0
		dad b			;HL=old z_r+z_i
		rst 5
						;(HL)=(z_r+z_i)^2
		pop b			;z_r2+z_i2
		mov a,m
		sub c
		mov e,a
		inx h
		mov a,m
		sbb b
		mov d,a			;DE=(z_r+z_i)^2-(z_r2+z_i2)
c_i		.equ $+1
		lxi h,0
		dad d			;HL=(z_r+z_i)^2-(z_r2+z_i2)+c_i
		pop d
		dcr e
		jnz Loopiter
		.db 0FEh
breakiter:
		pop d
ScrAdr	.equ $+1
		lxi h,0E000h
PixMask	.equ $+2
		lxi b,(11000000b*256)+0A0h
Pixel:
		mov a,e
		rrc
		mov e,a
		mov a,b
		jc $+6
		cma\ ana m\ .db 0FEh
		ora m
		mov m,a
		dcr l
		mov m,a
		inr l
		mov a,d\ add h\ mov h,a
		cmp c
		jnc Pixel
		mov a,b			;PixMask
		rrc
		rrc
		sta PixMask
		mvi a,96
		adc h
		sta ScrAdr+1
		mov e,l
		lhld c_r
DXY		.equ $+1
		lxi b,DXY0
		dad b
		jnz Loopxx
		xchg
		dcr l
		dcr l
		shld ScrAdr
		lhld c_i
		dad b
		jnz Loopyy
		mov a,c
SetZoom:
		jmp ZoomIn
ZoomOut:
		add a
		cpi 16
		jnz NoZoom16
		lxi h,SetZoom
		inr m
NoZoom16:
		lhld SetVIEW_I+1
		dad h
		.db 0C3h,MainLoop&255
		
		.end
