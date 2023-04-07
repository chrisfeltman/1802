;HRJ A18 wants register names defined...
	cpu 1802

R0		EQU	0
R1		EQU	1
R2		EQU	2
R3		EQU	3
R4		EQU	4
R5		EQU	5
R6		EQU	6
R7		EQU	7
R8		EQU	8
R9		EQU	9
R10		EQU	10
R11		EQU	11
R12		EQU	12
R13		EQU	13
R14		EQU	14
R15		EQU	15

r0		EQU	0
r1		EQU	1
r2		EQU	2
r3		EQU	3
r4		EQU	4
r5		EQU	5
r6		EQU	6
r7		EQU	7
r8		EQU	8
r9		EQU	9
ra		EQU	10
rb		EQU	11
rc		EQU	12
rd		EQU	13
re		EQU	14
rf		EQU	15

R0		EQU	0
R1		EQU	1
R2		EQU	2
R3		EQU	3
R4		EQU	4
R5		EQU	5
R6		EQU	6
R7		EQU	7
R8		EQU	8
R9		EQU	9
RA		EQU	10
RB		EQU	11
RC		EQU	12
RD		EQU	13
RE		EQU	14
RF		EQU	15

;==============================   ports ===============================

SEVEN_SEG	EQU 1
LCD_CMD 	EQU 2
LCD_CHAR	EQU 3

;==================== standard system reg settings ===================

TOPSTACK EQU 00ffh
PC EQU 3
SP EQU 2
INT EQU 1
CALLR EQU 4
RETR EQU 5
LINK EQU 6

;============================== start of code =========================

	ORG 0000h

boot_vect:
	br init

;   standard call convention notes
;======================================================================
;  April, 2023
;  my convention is, subroutine is not going to save D
;  if the caller needs to save D, it should push D before the call 
;  and restore it after, since D is needed for just about everything,
;  but way easier just to not rely on D after the return 
;  also, MARK is not being used here, so upon return, X will be pointing to SP (R2)
;  caller is responsible to SEX to whatever is needed after return 
;  after retrieving inline parameters, callee is responsible to inc R3 once for each
;  byte that is passed, so that upon return, R3 is pointing to the next instruction
;  after the call, also, callee is responsible to push and pop whatever R# it uses
;  before returning
;
;  note: for output subroutines, usually the first param will be a dword that is the 
;  address in mem of what is going to be output
;
;  for convenience, I have included both short_delay and long_delay built-in subs 
;  with short_delay taking a db and long_delay taking a dw param 

;======================= standard call boilerplate ==============================

sub_call_ret:
	sep PC
sub_call:
	SEX SP 		    ;SET R(X)
	GHI LINK
	STXD                ;SAVE THE CURRENT LINK ON
	GLO LINK
	STXD                ;THE STACK
	GHI PC
	PHI LINK
	GLO PC
	PLO LINK
	LDA LINK
	PHI PC              ;PICK UP THE SUBROUTINE
	LDA LINK
	PLO PC              ;ADDRESS
	BR sub_call_ret

sub_ret_ret: 
	SEP PC            ;RETURN TO MAIN PGM

; =========================  standard return boilerplate =========================

sub_ret:
	GHI LINK            ;recover calling program return addr
	PHI PC
	GLO LINK
	PLO PC
	SEX SP
	INC SP              ;SET THE STACK POINTER
	LDXA
	PLO LINK            ;RESTORE THE CONTENTS OF
	LDX
	PHI LINK            ;LINK
	BR sub_ret_ret


;========================== test subroutine call 


	
blink_q:
	seq ; q on 
	nop
	nop
	nop
	nop
	nop
	req; q off
	nop
	nop
	nop
	nop
	nop
	retn


;=========================   standard initialization ===========================

init:

	load SP, TOPSTACK
	;load INT int_vect
	load CALLR, sub_call
	load RETR, sub_ret
	load PC, main
	sep PC

;=========================   end init ===========================================

main:
	call blink_q
	call count
	call count_decimal
	br main


;===================   count subroutine ============================================
count:

	glo RF  ; save RF 
	stxd
	ghi RF
	stxd

	load RF, current_count
	sex RF
	out 1; display current count
	dec RF

	ldi 1; add one to count and store result
	add
	str RF

	ldi 100 ; if count == 100, reset
	sd
	bz reset
	br cleanup
reset:
	str RF

cleanup:

	sex SP
	irx   ; set stack pointer back to our stored data
	ldxa  ; restore RF
	phi RF
	ldx
	plo RF
	retn

	;============================ vars ==============================================
current_count:
	db 0

;======================== decimal count subroutine ==============================

count_decimal:
	
	load RA, decimal_count_1s
	load RB, decimal_count_10s
	load RC, decimal_count_output
	
	sex RA

	ldi 1 				
	add 				; calc ones digit + 1
	str RA 				; store it back

	ldi 10 				; check if we've hit 10
	sd 					; by subtracting

	bz reset_and_add10  ; if 1's digit is > 9
	br output


reset_and_add10:
		 
	str RA			; set it to 0 and
		
	sex RB 			; inc the 10's digit
	ldi 1
	add
	str RB

	ldi 10
	sd         		; subtract d
	bz reset_10s   ; reset to 0 if the 10's digit is > 9
	br output

reset_10s:

	str RB; reset it to 0

output:
	
	ldn RB 	; get 10s digit
	shl
	shl
	shl
	shl 	; shift left 4

	sex RA
	add 	; add 1s digit

	str RC  ; put to output slot

	sex RC
	out 1 	; display it
	
	retn

;========================== vars ===============================================
decimal_count_10s:
	db 0 

decimal_count_1s:
	db 0

decimal_count_output:
	db 0

;======================== double dabble to convert to BCD =====================
;  value to be converted passed in RA.0
; converted bcd value returned in RA

convert_bcd:
	ldi 0 		; using RA.1 to preserve the carry flag state between shift and test
	phi RA
	ldi 8 		; need to shift left 8 times
	plo RB
	

double_dabble:

	load RC, ones
	;shift left with carry on RA.0, ones_and_tens and hundreds
	glo RA
	shl  		; shift left, HO bit goes to DF
	plo RA 		; save shifted value temporarily
	ldn RC 		; get ones
	shlc  		; shift left with carry flag

	lsdf		; skip next 2 if there was a carry
	ldi 0 		; set RA.1 to 0

	lsnf 		; skip next 2 if there was NOT a carry
	ldi 1       ; set RA.1 to 1
	phi RA 		; RA.1 now contains the value of the carry bit

	sex RC

update_ones:

	
	ldn RC 		
	sdi, 5      ; is ones digit > 5 ?
	lsdf		; long skip if it was <= 5
	adi, 3      ; add 3 to the value
	str RC







retn

;======================= vars =================================================

ones:
	db 0
tens:
	db 0
hundreds: 
	db 0

	end