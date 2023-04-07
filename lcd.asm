	INCL "regdef.inc"

LCD_CMD EQU 2
LCD_CHAR EQU 3

START:
	sex RA				 	; RA = comand pointer
	load RA, DISPLAY_RESET	; init lcd
	
	out LCD_CMD
	nop
	nop
	nop
	out LCD_CMD 
	nop
	nop
	nop
	out LCD_CMD				;  send 3 times to insure display goes to correct mode
	nop
	nop
	nop
	load RA, FUNCTION_SET
	out LCD_CMD
	nop
	nop
	nop
	load RA, DISPLAY_OFF	
	out LCD_CMD
	nop
	nop
	nop
	load RA, CLEAR_DISPLAY
	out LCD_CMD
	nop
	nop
	nop
	load RA, ENTRY_MODE
	out LCD_CMD
	nop
	nop
	nop						; end LCD init
	load RA, DISPLAY_ON
	out LCD_CMD
	nop
	nop
	nop

resetmsg:
	load RA, mystring ; reg a -> mystring
loop:
	seq; set Q
	req; reset Q
	
	ldn RA;  check current byte
	bz clear;  if end of string, go back to start
	out P1;  output current char
	dec RA
	out LCD_CHAR
	nop
	br loop; next char

clear:
	load RA, CLEAR_DISPLAY
	out LCD_CMD
	nop
	nop
	br resetmsg


; vars above the code 
myvar 	db 0; just testing if we can reserve memory for vars and initialize them 
myotherVar db 0ah; ditto 
mystring TEXT "Hello, world!"; the string we are going to output
	db 0; null terminator, assembler does not allow \0 in the string 

CLEAR_DISPLAY 	db 00000001b ; long delay 1.52ms
HOME_CURSOR 	db 00000010b ; long delay 1.52ms
DISPLAY_RESET	db 00110000b ; 
FUNCTION_SET	db 00111000b ; 8 bit IF, 2 lines 5x7
DISPLAY_OFF		db 00001000b ;  display on 
ENTRY_MODE		db 00000110b ; cursor l/r no shift
DISPLAY_ON		db 00001100b ;  display on  



	END