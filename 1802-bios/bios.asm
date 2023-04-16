; my 1802 Operating System 
; Chris Feltman, April 2023

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

;============================= LCD commands
CLEAR_DISPLAY 	EQU 00000001b ; long delay 1.52ms
HOME_CURSOR 	EQU 00000010b ; long delay 1.52ms
DISPLAY_RESET	EQU 00110000b ; 
FUNCTION_SET	EQU 00111000b ; 8 bit IF, 2 lines 5x7
DISPLAY_OFF		EQU 00001000b ;  display on 
ENTRY_MODE		EQU 00000110b ; cursor l/r, shift on
DISPLAY_ON		EQU 00001100b ;  display on  
DISPLAY_SHIFT	EQU 00000111b ;  enable display shift
SCROLL_RIGHT	EQU $0018     ;

;==================== standard system reg settings ===================

TOPSTACK SET 07ffh	; top of our 32K of RAM
PC EQU 3
SP EQU 2
INT EQU 1
CALLR EQU 4
RETR EQU 5
LINK EQU 6

;============================== start of code =========================

	ORG 0000h

boot_vect:
	
	load PC, init
	sep PC

;   standard call convention notes
;======================================================================
;  April, 2023
;  my convention is, subroutine is not going to save D, nor RA, RB, RC or RD
;  if the caller needs to save D, it should push D before the call 
;  and restore it after, since D is needed for just about everything,
;  but way easier just to not rely on D after the return 
;  also, MARK is not being used here, so upon return, X may or may not be pointing to SP (R2)
;  caller is responsible to SEX to whatever is needed after return 
;  after retrieving inline parameters, callee is responsible to inc R3 once for each
;  byte that is passed, so that upon return, R3 is pointing to the next instruction
;  after the call, also, callee is responsible to push and pop whatever R# it uses
;  before returning, except for RA, RB, RC and RD

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


;========================= delay system call  =================================
;	dword delay value passed in REG A

delay:

	glo RA
	bnz delay_dec
	ghi RA				; if lo byte is 0, see if the high byte is too 
	bz delay_exit		; if both bytes are 0, we are done

delay_dec:		; just dec the count and go back 

	dec RA
	br delay

delay_exit:

	retn

;====================== init 7 seg system call ===========================================
init_sevenseg:
	load RA, sevenseg_out
	sex RA
	out SEVEN_SEG
	retn
sevenseg_out:
	db 0


;====================== init LCD system call =============================================
; clobbers RA, RB, D ... no regrets, deal with it
; you lose 10 bytes of mem if you want the display
; using the stack won't help because the ops would use as much mem as we would save
; ditto using R7 - RF

; note: at fastest 1802 clock speeds, delay 5 might not be enough
; easier to change the code than to wire up to read display busy

init_lcd:

	ldi 0
	phi RA 					; we only need 8 bit delay for LCD commands
	load RB, init_sequence	; set up cmd sequence 

init_lcd_loop:
	sex RB
	out LCD_CMD			; send next setup cmd to LCD controller
	
	ldi 1				; worst case delay scenario for LCD commands
	plo RA				; not all take this long, but we are only doing this once
	call delay

	ldn RB
	bnz init_lcd_loop 	; if not end, send next cmd
	load RA, init_msg
	call output_string
	call clear_display

	retn

init_sequence:

	db DISPLAY_RESET
	db DISPLAY_RESET
	db DISPLAY_RESET
	db FUNCTION_SET
	db DISPLAY_OFF
	db CLEAR_DISPLAY
	db ENTRY_MODE
	db DISPLAY_ON
	db HOME_CURSOR
	db 0

init_msg:
	text "1802 COSMAC Microkernel BIOS, CF 2023"
	db 0

;========================== output string system call ==================================
; RA -> output string terminated by $00
; clobbers: D, X, RB

output_string:
	load RB, char_count ; set char count to 0
	ldi 0
	str RB
	
output_string_loop:
	sex RA	; RA is our output pointer, X changes to RB to check count, so always reset
	load RB, char_count
	ldn RA
	bz output_string_done
	out LCD_CHAR

	ldn RB; get char count
	adi 1
	str RB; add 1 to count
	sex RB
	

	; subtract 16 
	ldi 16
	sd
	bl output_string_loop

	; todo: make scroll_display its own subroutine
	
	load RB, lcd_cmd_byte
	ldi SCROLL_RIGHT  ;send a scroll command 
	str RB
	out LCD_CMD

	br output_string_loop

output_string_done:
	retn

char_count:   ; keep count of output for auto-scroll
	db 0
lcd_cmd_byte:
	db 0

;================================ hex to ascii system call ==============================
; input: hex value in A.0
; clobbers: RA, D
; returns: ASCII in hex_to_ascii_value

hex_to_ascii:

	sex R2   	; push RB
	ghi RB
	stxd 
	glo RB
	str R2

	load RB, hex_to_ascii_value
	ldi 0
	str RB	; init mem buffer to 00
	inc RB
	str RB
	dec RB

	glo RA		
	ani 0f0h	; get hi nybble only
	shr
	shr
	shr
	shr			; shift right 4x to lo nybble
	phi RA		; stash orig value
	sdi 09h		; subtract 9
	bnf add_37	; if >-= 10, add 0x37
	ghi RA		; retrieve orig value
	adi 30h		; convert to ascii 
	br store_hi_ascii_char
	

add_37:
	ghi RA			; retrieve orig value 
	adi 37h 		; convert to ascii

store_hi_ascii_char:	
	str RB		; store in hex_to_ascii_value [0]

	inc RB		; go to next ascii char slot

	glo RA		
	ani 0fh		; get the lo nybble only
	phi RA		; stash orig value
	sdi 09h		; subtract 9
	bnf add_37_2	; if >-= 10, add 0x37
	ghi RA		; retrieve orig value 
	adi 30h   	; convert to ascii
	br store_lo_ascii_char

add_37_2:
	ghi RA		; retrieve orig value
	adi 37h		; convert to ascii

store_lo_ascii_char:
	str RB		; store in hex_to_ascii_value [1]

	ldxa 		; restore RB
	plo RB
	ldn R2
	phi RB
	retn

hex_to_ascii_value:
	db 0
	db 0
	db 0




;================================ scroll display system call ============================
; clobbers D

scroll_display:

	sex R2
	ghi RB
	stxd 
	glo RB
	str R2
	sex RB
	load RB, lcd_cmd_byte
	ldi SCROLL_RIGHT  ;send a scroll command 
	str RB
	out LCD_CMD
	sex R2
	ldxa 
	plo RB
	;ldn R2
	ldxa
	phi RB
	retn

;================================ clear display system call ============================
; clobbers D, RA, RB, X

clear_display:
	load RB, display_cmd
	ldi CLEAR_DISPLAY
	str RB
	sex RB
	out LCD_CMD
	ldi 0
	phi RA
	ldi 5
	plo RA
	call delay
	retn
display_cmd:
	db 0;

;========================== blink Q system call =========================================
; clobbers RA, D

blink_q:
	ldi 0
	phi RA
	seq ; q on 
	ldi 5
	plo RA
	call delay
	req
	ldi 5
	plo RA
	call delay
	retn

;=========================   standard initialization ===========================

init:

	load SP, TOPSTACK
	;load INT int_vect
	load CALLR, sub_call
	load RETR, sub_ret
	call init_sevenseg
	call init_lcd
	load PC, main
	sep PC

;=========================   end init ===========================================


