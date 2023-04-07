	INCL "regdef.inc"

LCD_CMD EQU 2
LCD_CHAR EQU 3

START:
	load RB, delay
	sex RA				 	; RA = comand pointer
	load RA, DISPLAY_RESET	; init lcd
	
	out LCD_CMD
	sep RB

	out LCD_CMD 
	sep RB

	out LCD_CMD				;  send 3 times to insure display goes to correct mode
	sep RB
	load RA, FUNCTION_SET
	out LCD_CMD
	sep RB
	load RA, DISPLAY_OFF	
	out LCD_CMD
	sep RB
	load RA, CLEAR_DISPLAY
	out LCD_CMD
	sep RB
	load RA, ENTRY_MODE
	out LCD_CMD
	sep RB				; end LCD init
	

	load RA, DISPLAY_ON
	out LCD_CMD
	sep RB
	load RA, HOME_CURSOR
	sep RB

resetmsg:
	load RB, output_string  ; our output subroutine
	load RA, mystring 		; reg a -> null-terminated string to output
	
	sep RB					; call output 
	load RA, mystring2
	sep RB					; call output
	load RA, mystring3
	sep RB					; call output
	load RA, mystring4
	sep RB
	load RA, mystring5		; TODO, use pointer to string array 
	sep RB
	load RA, mystring6
	sep RB
	load RA, mystring7
	sep RB
	load RA, mystring8
	sep RB
	load RA, mystring9
	sep RB
	br resetmsg


output_string_ret:
	sep R0	; return

output_string:
	load RD, char_pos
	ldi 0
	str RD;   reset char pos counter

output_loop:

	seq; set Q
	ldn RA;  check current byte
	bz clear;  if end of string, go back to start
	out P1;  output current char
	dec RA
	out LCD_CHAR
	nop
	ldn RD; get count
	adi 1
	str RD; add 1 to count
	ldi 16; 16 chars is all that will fit before lcd needs to scroll
	sex RD; x = RD
	sm 		; subtract char count from D, if > 16 need to scroll 
	bge no_scroll

	load RE, SCROLL_RIGHT; send a scroll right command
	sex RE  ; use RE to send 
	out LCD_CMD
	nop 
	nop
	nop
	nop
	nop

no_scroll:
	sex RA;  set X back to RA
	req; reset Q
	br output_loop 	; next char

clear:
	load RA, CLEAR_DISPLAY
	out LCD_CMD
	nop
	nop
	nop
	nop
	nop
	br output_string_ret

; lcd delay subroutine
delay_ret:
	sep R0
delay:
	load RC, 0005h
delay_loop:
	dec RC
	glo RC
	bnz delay_loop
	br delay_ret


; vars above the code 
char_pos db 0

mystring TEXT "Hello, world!"; 
	db 0; null terminator, assembler does not allow \0 in the string 

mystring2 TEXT "I am a COSMAC 1802 CPU with 32K of RAM"
	db 0;

mystring3 TEXT "My display is VERY emo..."
	db 0;

mystring4 TEXT "I live to serve my master, Christopher."
	db 0;

mystring5 TEXT "My stack runneth over,"
	db 0;

mystring6 TEXT "Thy will be done."
	db 0;

mystring7 TEXT "Be careful! I byte!!!"
	db 0;

mystring8 TEXT "Just kidding! I only nybble..."
	db 0;

mystring9 TEXT "Would you like to play a game???"
	db 0;

CLEAR_DISPLAY 	db 00000001b ; long delay 1.52ms
HOME_CURSOR 	db 00000010b ; long delay 1.52ms
DISPLAY_RESET	db 00110000b ; 
FUNCTION_SET	db 00111000b ; 8 bit IF, 2 lines 5x7
DISPLAY_OFF		db 00001000b ;  display on 
ENTRY_MODE		db 00000110b ; cursor l/r, shift on
DISPLAY_ON		db 00001100b ;  display on  
DISPLAY_SHIFT	db 00000111b ;  enable display shift
SCROLL_RIGHT	db $0018     ;



	END