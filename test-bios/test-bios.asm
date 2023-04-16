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
	load RB, count
	ldn RB
	plo RA
	call hex_to_ascii
	load RA, hex_to_ascii_value

	call output_string
	call clear_display
	
	lbr main

show_count:
	load RA, count ; show loop iterations on 7 seg
	ldn RA
	adi 1
	str RA
	sex RA
	out SEVEN_SEG
	retn

out:
	text "My program is cool............."
	db 0
out2:
	text "Too bad you're not!!!!!!!!!!!!!"
	db 0
count:
	db 0

	end

