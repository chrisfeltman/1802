	INCL "regdef.inc"

START:
	load RA, mystring ; reg a -> mystring
	seq; set Q
	req; reset Q
	sex RA;  A becomes the output pointer
loop:	
	ldn RA;  check current byte
	bz START;  if end of string, go back to start
	out P1;  output current char
	br loop; next char

; vars above the code 
myvar 	db 0; just testing if we can reserve memory for vars and initialize them 
myotherVar db 0ah; ditto 
mystring TEXT "Hello, world!"; the string we are going to output
	db 0; null terminator, assembler does not allow \0 in the string 

	END