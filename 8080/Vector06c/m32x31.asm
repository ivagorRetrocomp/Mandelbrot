;Mandelbrot 32x31 with "scroll" for Vector06c
;Ivan Gorodetsky
;v 1.0 - 15.12.2021 (219 bytes, 1.4 FPS)
;v 1.1 - 17.12.2021 (218 bytes, 2.0 FPS)
;
;Compile with The Telemark Assembler (TASM) 3.2


SQRTab	.equ (14*256)
MAXITER	.equ 8
ROWS	.equ 31
VIEW_R	.equ -40
VIEW_I	.equ -30

		.org 0100h

		di
		lxi h,0038h
		mvi m,0C9h
		sphl
		ei
		hlt
		mvi a,88h
		out 0
		mvi c,(SQRTab+256)>>8
		mov d,c
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
		mov e,a
		mov l,a
		mov b,c
MakeSQRTabLoop:
		push h
		xra a
		dad h\ adc a
		dad h\ adc a
		dad h\ adc a
		dad h\ adc a
		mov l,a
		stax d
		push d
		dcr d
		xchg
		mov m,d
		mov a,l\ cma\ inr a\ mov l,a
		mov m,d
		inr h
		mov m,e
		pop d
		inr e
		pop h
		inx b
		inx b
		dad b
		mvi a,129
		cmp e
		jnz MakeSQRTabLoop

MainLoop:	
		mvi a,VIEW_I
Loopyy:
		sta c_i
		mvi a,VIEW_R
Loopxx:
		sta c_r
		sta z_r
		lda c_i
		sta z_i
		mvi b,MAXITER-1
Loopiter:
		push b
z_r		.equ $+1
		lxi h,SQRTab
		mov c,m
		inr h
		mov b,m			;BC=z_r2
z_i		.equ $+1
		mvi l,0
		mov d,m
		dcr h
		mov e,m			;DE=z_i2
		xchg
		mov e,l
		dad b			;HL=z_r2+z_i2
		mvi a,(4*16)-1
		cmp l
		mvi a,0
		sbb h
		jc breakiter
		lda z_r
		lxi h,z_i
		add m			;A=z_r+z_i
		mov l,a
		mvi h,SQRTab>>8
		mov a,m			;A=LOW((z_r+z_i)^2)
		sub e			;A=(z_r+z_i)^2-z_i2
		sub c			;A=(z_r+z_i)^2-z_i2-z_r2
c_i		.equ $+1
		adi 0
		sta z_i			;z_i=(z_r+z_i)^2-z_i2-z_r2+c_i
c_r		.equ $+1
		mvi a,0
		add c
		sub e
		sta z_r			;z_r=z_r2-z_i2+c_r
		pop b
		dcr b
		jnz Loopiter
		.db 0FEh		;cpi ...
breakiter:
		pop b			;B=iter
ScrAdr	.equ $+1
		lxi h,0E000h
		mov d,h
		mov e,l
Draw:
		mov a,b
		rrc
		mov b,a
		sbb a
		mov m,a\ dcr l
		mov m,a\ dcr l
		mov m,a\ dcr l
		mov m,a\ dcr l
		mov m,a\ dcr l
		mov m,a\ dcr l
		mov m,a\ dcr l
		mov m,a
		mov l,e
		mvi a,-32\ add h\ mov h,a
		cpi 0A0h
		jnc Draw
		xchg
		lda c_r
		adi 2
		inr h
		shld ScrAdr
		jnz Loopxx
		mvi h,0E0h
		mvi a,-8
		add l
		mov l,a
		shld ScrAdr
		lda c_i
		adi 2
		cpi (ROWS*2)+VIEW_I
		jnz Loopyy
		jmp MainLoop

		.end
