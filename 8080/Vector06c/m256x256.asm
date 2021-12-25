;Mandelbrot 256x256 (MAXITER=16) with zoom for Vector06c
;Ivan Gorodetsky
;v 1.12 - 25.12.2021 (364 bytes)
;
;Compile with The Telemark Assembler (TASM) 3.2


SQRTab	.equ 1000h
MAXITER .equ 16
VIEW_I	.equ -1024;
DXY0	.equ 16

Mask	.equ 11111b		;for scale=256

		.org 0100h

		di
		xra a
		out 10h
		mov d,a
		mov e,a
		lxi h,0038h
		mvi m,0C9h
		sphl
		ei
		hlt
		mvi a,88h
		out 0
		mvi c,15
		lxi h,Palette+15
SetPal:
		mov a,c
		out 2
		mov a,m
		out 0Ch
		rst 7
		rst 7
		dcx h
		dcr c
		out 0Ch
		jp SetPal
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
		mvi a,DXY0
ZoomIn:
		rar
		mov c,a
		cpi 4
		jnz ZoomNot4
		lxi h,ViewRtab+2
		shld NoZoom1+1
		jmp NoZoom1
ZoomNot4:		
		dcr a
		jnz NoZoom1
		lxi h,SetZoom
		dcr m
		jmp SetVIEW_I
NoZoom1:
		lxi h,ViewRtab
		mov e,m\ inx h\ mov d,m\ inx h
		shld NoZoom1+1
		xchg
		shld SetVIEW_R+1
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
SetVIEW_R:
		lxi h,-1024
Loopxx:
		shld c_r
		shld z_r
		lhld c_i
		mvi d,MAXITER-1
Loopiter:
		shld z_i
		push d
		dad h
		mvi a,Mask\ ana h\ adi SQRTab>>8\ mov h,a
		mov e,m
		inx h
		mov d,m			;DE=z_i2
z_r		.equ $+1
		lxi h,0
		dad h
		mvi a,Mask\ ana h\ adi SQRTab>>8\ mov h,a
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
		dad h
		mvi a,Mask\ ana h\ adi SQRTab>>8\ mov h,a
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
		dad d			;HL=z_i=(z_r+z_i)^2-z_i2-z_r2+c_i
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
PixMask	.equ $+2
		lxi b,(10000000b*256)+080h
Pixel:
		mov a,d
		rrc
		mov d,a
		mov a,b
		jc $+6
		cma\ ana m\ .db 0FEh
		ora m
		mov m,a
		mvi a,-32\ add h\ mov h,a
		cmp c
		jnc Pixel
		mov a,b			;PixMask
		rrc
		sta PixMask
		mvi a,128
		adc h
		xchg
		sta ScrAdr+1
		lhld c_r
DXY		.equ $+1
		lxi b,DXY0
		dad b
		jnz Loopxx
		xchg
		mvi h,0E0h
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
		cpi 8
		jnz NoZoom8
		lxi h,SetZoom
		inr m
		lxi h,ViewRtab+2
		shld NoZoom1+1
NoZoom8:
		lhld NoZoom1+1
		dcx h\ mov d,m\ dcx h\ mov e,m
		shld NoZoom1+1
		xchg
		shld SetVIEW_R+1
NoZoom8_:
		lhld SetVIEW_I+1
		dad h
		jmp MainLoop
Palette:
		.db 0
		.db 0+(0*8)+(2*64)
		.db 0+(0*8)+(3*64)
		.db 0+(1*8)+(3*64)
		.db 0+(3*8)+(3*64)
		.db 0+(5*8)+(3*64)
		.db 0+(7*8)+(3*64)
		.db 1+(7*8)+(2*64)
		.db 3+(7*8)+(1*64)
		.db 5+(7*8)+(0*64)
		.db 7+(7*8)+(0*64)
		.db 7+(5*8)+(0*64)
		.db 7+(3*8)+(0*64)
		.db 7+(1*8)+(0*64)
		.db 7+(0*8)+(0*64)
		.db 5+(0*8)+(0*64)
ViewRtab:
		.dw -1024,-512,-384
		
		.end
