	INCL '../1802-bios/bios.asm'

main:

	call blink_q
	load RA, out
	call output_string
	call clear_display
	load RA, out2
	call output_string
	call clear_display
	call show_count
	call show_even_odd
	call verify_stackptr

	; test self-modifying code .. GULP!!!!

	load RA, main
	load RB, dynamic_branch_target

	; you shouldn't be doing this ... 

	ghi RA
	str RB		; self modify dynamic br target hi byte
	inc RB
	glo RA
	str RB		; self modify dynamic br target lo byte

	; umm, are you sure about this? this is crazy ... 
	; you've got an embedded opcode here, and a label for a data byte 
	; that is IN THE INSTRUCTION STREAM!!!!

	db 0c0h					; C0 = long branch to ....
dynamic_branch_target:
	dw 0000h				; whatever gets written here

	;lbr main


verify_stackptr:
	
	; verify that stack pointer is where we expect it to be, 0x07fb

	load RA, stack_msg
	call output_string

	; display stack pointer value on lcd

	ghi R2		; get high byte of stack pointer
	plo RA
	load RB, hex_to_ascii_value
	call hex_to_ascii
	
	load RA, hex_to_ascii_value
	call output_string				; show on lcd

	glo R2		; get low byte of stack pointer
	plo RA
	load RB, hex_to_ascii_value
	call hex_to_ascii
	load RA, hex_to_ascii_value
	call output_string				; show on lcd
	call clear_display
	retn

	
show_even_odd:

	ldn RA
	ani 1
	bnz im_odd
	load RA, even_msg
	br output_even_odd_msg

im_odd:
	load RA, odd_msg

output_even_odd_msg
	call output_string
	call clear_display
	retn


show_count:
	load RA, count ; show loop iterations on 7 seg
	ldn RA
	adi 1
	str RA
	sex RA
	out SEVEN_SEG
	dec RA			; put RA back for even/odd call
	retn



odd_msg: 
	text "I'm odd"
	db 0

even_msg: 
	text "I'm even"
	db 0
out:
	text "My program is cool............."
	db 0
out2:
	text "Too bad you're not!!!!!!!!!!!!!"
	db 0
count:
	db 0

stack_msg:
	text "Stack ptr: "
	db 0

x_msg:
	text "X: "
	db 0

hex_to_ascii_value:
	db 0
	db 0
	db 0


	end

