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
	lbr main


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
	load RA, odd_flag
	ldn RA
	xri 1
	str RA
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
	retn

odd_flag:
	db 0

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

d_msg:
	text "D: "
	db 0

hex_to_ascii_value:
	db 0
	db 0
	db 0


	end

