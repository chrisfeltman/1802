	INCL "regdef.inc"



init:

	load R2, $7fff 	; set stack pointer to top of mem
	load R3, start 	; use R3 as our PC
	
	sep R3 ; now running at start

start: 
	sex R4;   		; use R4 as our var pointer
	load R4, state
	ldi 1 	; state 1, in main loop 
	str R4  ; save to mem
	out 1 	; show current state
	nop
	nop
	nop
	nop
	nop 	; leave enough time for state 1 to show on display
	sex R2
	mark 	; save current state to stack

	ldi $04 ; pass 4 to delay sub
	str R2	; push onto stack

	load R5, stack_param
	ldn R2 ; lets see whats on the stack
	str R5
	sex R5
	out 1
	nop
	nop
	nop
	nop
	nop
	nop
	load R5, delay
	sep R5 	; call delay subroutine
	dec R2 ; fix SP
	

	sex R4;   		; use R4 as our var pointer

	load R4, state
	ldi 1 	; state 1, in main loop 
	str R4  ; save to mem
	out 1 	; show current state
	nop
	nop
	nop
	nop
	nop 	; leave enough time for state 1 to show on display
	sex R2
	mark 	; save current state to stack
	load R5, delay
	ldi $0A; delay 2nd time
	str R2	; push onto stack
	sep R5	; call delay again	
	dec R2 ; fix SP

	br start; go back to the beginning


delay_ret:
	
	sex R2 	; ret assumes nothing about the stack pointer, X MUST be 2 before ret

	ldxa	; restore RF
	phi RF
	ldxa
	plo RF
	inc R2	; remove delay param from stack 
	ret

delay: 		; delay subroutine	, delay passed in RF.0


delay_init:
	sex R2 

	dec R2
	glo RF
	stxd
	ghi RF
	str R2

	inc R2
	inc R2
	
	ldn R2 	; get count param
	
	plo RF; put in RF as counter

	dec R2
	dec R2 ; put the stack pointer back where it belongs

	sex R4;  
	load R4, state
	ldi 2 	; state = 2, in delay sub
	str R4 	; update state .. should show 2 on 7seg while in delay sub
	out 1 	; display the state on 7seg
	
	
	
	
delay_loop:
	seq; turn on led 
	
	nop 
	nop
	nop
	nop
	nop

	req   ; turn off led
	
	glo RF
	bz delay_ret ; loop until count is 0
	dec RF
	br delay_loop;  exit sub

; vars 
state db 1
stack_addr dw $0000
stack_param db 0


	END
