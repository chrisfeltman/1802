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

TOPSTACK EQU 07ffh
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

blink_q_ret:
	RETN
	
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
	br blink_q_ret


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
	br main
	end
