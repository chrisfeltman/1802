	org	1220H		;have to start somewhere ...
R5	equ	5		;A18 needs registers symbols defined as values 0-15 decimal

	ldi	start.1	;RCA assembler for high byte of symbol or expression
	ldi	start.0	; and low byte of symbol or expression
	ldi	start.0 + 5
	ldi	(start+5).0 ;a little ugly, does it work?

	ldi	$.0 		;gets low-byte of assembly addr
	ldi	$.0 + 4	;and four bytes ahead

	ldi	A.0		;making trouble here ...
	ldi	A.0(start)	;this A.0 A.1 feature in RCA assembler is 
				;a syntax error in A18 (even if A is a symbol, bad idea) try following
	ldi	low(start)	;if you want literal RCA asm translation use low, high

	;it's common in RCA source to use say "R5.1" to refer to low-byte of R5. But...
	ldi	R5.1		;not an A18 error because it looks like following
	ldi	(5).1		; but 1802 codes don't work this way, see following
	ghi	R5		;ghi glo phi plo work with register bytes

	org	1234h
start: db	00
A:	db 00

	end
